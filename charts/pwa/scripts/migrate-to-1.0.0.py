#!/usr/bin/env python3
"""Migrate Intershop PWA Helm values from the 0.x layout to the 1.0.0 layout.

Flux ``HelmRelease`` documents are migrated only when their chart is ``pwa-main`` (the tool
transforms ``spec.values`` and bumps ``spec.chart.spec.chart`` -> ``pwa`` and ``version``).
A bare 0.x values file is migrated too, but only when passed **explicitly as an input file** --
directory batch scans (``-r``) process HelmReleases only, so mixed trees stay safe. Any other
document is left untouched. Comments/formatting are preserved via ruamel.yaml round-tripping.

The 0.x -> 1.0.0 mapping mirrors charts/pwa/docs/migrate-to-1.0.0.md:
  * top-level SSR keys        -> app.<key>
  * environment               -> app.env
  * cache.*                   -> proxy.*   (cache.extraEnvVars -> proxy.env)
  * upstream.icmBaseURL       -> config.icmBaseUrl (required)
  * top-level allowedHosts    -> config.allowedHosts
  * ICM_BASE_URL_SSR/ALLOWED_HOSTS env entries -> config.icmBaseUrlSsr/allowedHosts
  * upstream.cdnPrefixURL, cache.prefetch, cache.init, calculated -> removed

Usage:
  python migrate-to-1.0.0.py PATH [PATH ...] [options]

  PATH may be a file or a directory (use -r to recurse). By default the tool runs
  as a dry-run and only reports what it would change. Use --write to apply.

Options:
  -w, --write            Write changes back to the file(s).
      --backup           With --write, keep a <file>.bak copy of the original.
  -o, --output-suffix S  Instead of in-place, write to <stem><S> (e.g. .1.0.0.yaml).
  -r, --recursive        Recurse into directories.
      --glob PATTERN     File pattern when scanning directories (default *.y*ml).
      --target-version V Chart version to set (default 1.0.0).
      --no-lift-env      Keep ICM_BASE_URL_SSR/ALLOWED_HOSTS in app.env (don't lift to config).
      --show-diff        Print a unified diff of the changes.
"""
from __future__ import annotations

import argparse
import difflib
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    from ruamel.yaml import YAML
    from ruamel.yaml.comments import CommentedMap, CommentedSeq
except ImportError:  # pragma: no cover
    sys.exit("This tool requires ruamel.yaml. Install it with:\n  python -m pip install ruamel.yaml")

MIGRATABLE_CHART = "pwa-main"   # only Flux HelmReleases using this chart are migrated
NEW_CHART_NAME = "pwa"
DEFAULT_TARGET_VERSION = "1.0.0"
# Raw base for the version-pinned $schema modeline added by --add-schema.
SCHEMA_BASE = "https://raw.githubusercontent.com/intershop/helm-charts"

# 0.x top-level SSR keys that move verbatim under app.<key>.
SSR_KEYS = [
    "replicaCount", "image", "service", "resources", "metrics", "updateStrategy",
    "livenessProbe", "readinessProbe", "startupProbe", "nodeSelector", "tolerations",
    "affinity", "podAntiAffinity", "podAnnotations", "podLabels",
    "deploymentAnnotations", "deploymentLabels", "autoscaling",
]
CACHE_RENAME = {"extraEnvVars": "env"}          # cache.<old> -> proxy.<new>
CACHE_REMOVE = {"prefetch", "init"}             # dropped in 1.0.0
REMOVED_TOP = ["calculated"]                    # top-level keys dropped in 1.0.0
ENV_TO_CONFIG = {"ICM_BASE_URL_SSR": "icmBaseUrlSsr", "ALLOWED_HOSTS": "allowedHosts"}
# 0.x top-level keys that are still valid at the top level in 1.0.0.
KEEP_TOP = {"nameOverride", "fullnameOverride", "hybrid", "imagePullSecrets", "ingress", "config", "app", "proxy"}


class Report:
    """Collects per-file changes for human-readable output."""

    def __init__(self, label: str):
        self.label = label
        self.maps: list[tuple[str, str]] = []
        self.removed: list[str] = []
        self.warnings: list[str] = []
        self.info: list[str] = []
        self.targets: list = []   # migrated values maps, for optional --validate

    def map(self, src: str, dst: str) -> None:
        self.maps.append((src, dst))

    def remove(self, key: str) -> None:
        self.removed.append(key)

    def warn(self, msg: str) -> None:
        self.warnings.append(msg)

    def note(self, msg: str) -> None:
        self.info.append(msg)

    @property
    def changed(self) -> bool:
        return bool(self.maps or self.removed)

    def render(self) -> str:
        lines = [f"\n=== {self.label} ==="]
        if not self.changed and not self.warnings:
            lines.append("  already 1.0.0 compatible — no changes")
        for src, dst in self.maps:
            lines.append(f"  moved    {src}  ->  {dst}")
        for key in self.removed:
            lines.append(f"  removed  {key}  (no 1.0.0 equivalent)")
        for msg in self.warnings:
            lines.append(f"  WARNING  {msg}")
        for msg in self.info:
            lines.append(f"  note     {msg}")
        return "\n".join(lines)


def _ensure(store: dict, key: str) -> CommentedMap:
    node = store.get(key)
    if not isinstance(node, CommentedMap):
        node = CommentedMap()
        store[key] = node
    return node


def migrate_values(values: CommentedMap, report: Report, lift_env: bool = True) -> bool:
    """Transform a 0.x values mapping in place. Returns True if anything changed."""
    if not isinstance(values, dict):
        return False

    config = CommentedMap()
    app = CommentedMap()
    proxy = CommentedMap()

    # upstream.* -> config.*
    if "upstream" in values:
        up = values.pop("upstream")
        if isinstance(up, dict):
            if "icmBaseURL" in up:
                config["icmBaseUrl"] = up.pop("icmBaseURL")
                report.map("upstream.icmBaseURL", "config.icmBaseUrl")
            for rem in ("cdnPrefixURL", "icm"):
                if rem in up:
                    up.pop(rem)
                    report.remove(f"upstream.{rem}")
            for leftover in list(up.keys()):
                report.warn(f"upstream.{leftover} has no 1.0.0 mapping; dropped")
        report.map("upstream", "config")

    # top-level config-ish keys
    for old, new in (("allowedHosts", "allowedHosts"), ("icmBaseUrlSsr", "icmBaseUrlSsr")):
        if old in values:
            config[new] = values.pop(old)
            report.map(old, f"config.{new}")

    # environment -> app.env
    if "environment" in values:
        app["env"] = values.pop("environment")
        report.map("environment", "app.env")

    # top-level SSR keys -> app.<key>
    for key in SSR_KEYS:
        if key in values:
            app[key] = values.pop(key)
            report.map(key, f"app.{key}")

    # cache.* -> proxy.*
    if "cache" in values:
        cache = values.pop("cache")
        if isinstance(cache, dict):
            for ck in list(cache.keys()):
                if ck in CACHE_REMOVE:
                    cache.pop(ck)
                    report.remove(f"cache.{ck}")
                elif ck in CACHE_RENAME:
                    nk = CACHE_RENAME[ck]
                    proxy[nk] = cache.pop(ck)
                    report.map(f"cache.{ck}", f"proxy.{nk}")
                else:
                    proxy[ck] = cache.pop(ck)
                    report.map(f"cache.{ck}", f"proxy.{ck}")
        report.map("cache", "proxy")

    # removed top-level keys
    for key in REMOVED_TOP:
        if key in values:
            values.pop(key)
            report.remove(key)

    # lift ICM_BASE_URL_SSR / ALLOWED_HOSTS out of app.env into config.*
    if lift_env and isinstance(app.get("env"), list):
        env = app["env"]
        for i in range(len(env) - 1, -1, -1):
            item = env[i]
            if isinstance(item, dict) and item.get("name") in ENV_TO_CONFIG and "value" in item:
                target = ENV_TO_CONFIG[item["name"]]
                config[target] = item["value"]
                report.map(f"app.env[{item['name']}]", f"config.{target}")
                del env[i]
        if len(env) == 0:
            app.pop("env")

    # insert the new tiers at the front (config, app, proxy), preserving other keys/comments
    for key, node in (("proxy", proxy), ("app", app), ("config", config)):
        if node:
            if key in values:  # merge into any pre-existing 1.0 block
                values[key].update(node)
            else:
                values.insert(0, key, node)

    # flag any leftover unknown top-level keys
    for key in list(values.keys()):
        if key not in KEEP_TOP:
            report.warn(f"top-level '{key}' is not a known 1.0.0 key; left unchanged — review manually")

    return report.changed


def _looks_like_0x_values(doc) -> bool:
    """Heuristic: a bare (non-HelmRelease) mapping that still uses the 0.x PWA layout."""
    markers = {"upstream", "cache", "environment", *SSR_KEYS}
    return isinstance(doc, dict) and any(k in doc for k in markers) and "proxy" not in doc


def migrate_doc(doc, args, report: Report, allow_bare: bool = False) -> bool:
    # Flux HelmReleases are migrated only when their chart is `pwa-main`. Bare values files
    # (no `kind: HelmRelease`) are migrated only when passed explicitly as an input file
    # (allow_bare=True); directory batch scans never touch them, to stay safe on mixed trees.
    if not isinstance(doc, dict):
        return False
    if doc.get("kind") != "HelmRelease":
        if allow_bare and _looks_like_0x_values(doc):
            migrate_values(doc, report, lift_env=not args.no_lift_env)
            report.targets.append(doc)
            return report.changed
        report.note("not a Flux HelmRelease -- skipped")
        return False
    spec = doc.get("spec")
    chart = spec.get("chart") if isinstance(spec, dict) else None
    chartspec = chart.get("spec") if isinstance(chart, dict) else None
    name = chartspec.get("chart") if isinstance(chartspec, dict) else None
    if name != MIGRATABLE_CHART:
        report.note(f"HelmRelease chart is '{name}', not '{MIGRATABLE_CHART}' — skipped")
        return False
    chartspec["chart"] = NEW_CHART_NAME
    report.map(f"chart: {MIGRATABLE_CHART}", f"chart: {NEW_CHART_NAME}")
    ver = str(chartspec.get("version", ""))
    if ver.startswith("0."):
        chartspec["version"] = args.target_version
        report.map(f"version: {ver}", f"version: {args.target_version}")
    if "valuesFrom" in spec:
        report.warn("spec.valuesFrom present — external values are NOT migrated by this tool")
    if isinstance(spec.get("values"), dict):
        migrate_values(spec["values"], report, lift_env=not args.no_lift_env)
        report.targets.append(spec["values"])
    return report.changed


def _new_yaml() -> YAML:
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 1_000_000          # never wrap long scalars (e.g. the denylist CIDR string)
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.explicit_start = True
    return yaml


def _dump_all(yaml: YAML, docs: list) -> str:
    buf = io.StringIO()
    for doc in docs:
        yaml.dump(doc, buf)
    return buf.getvalue()


def _chart_dir_default() -> Path:
    # scripts/ lives inside the chart, so the chart dir is its parent.
    return Path(__file__).resolve().parents[1]


def _with_schema_modeline(text: str, target_version: str, is_helmrelease: bool) -> str:
    """Prepend a yaml-language-server $schema modeline (replacing any existing one).

    HelmRelease files reference the Flux schema (which validates spec.values); bare values
    files reference the values schema directly. The URL is pinned to the target chart version.
    """
    schema = "values-flux.schema.json" if is_helmrelease else "values.schema.json"
    url = f"{SCHEMA_BASE}/pwa-{target_version}/charts/pwa/{schema}"
    modeline = f"# yaml-language-server: $schema={url}"
    body = [ln for ln in text.split("\n") if not re.match(r"\s*#\s*yaml-language-server\s*:", ln)]
    return modeline + "\n" + "\n".join(body)


def _validate_values(values, chart_dir: Path, yaml: YAML) -> list[str]:
    """Render migrated values against the chart; return error lines ([] means it validates)."""
    if shutil.which("helm") is None:
        return ["helm not found on PATH -- cannot validate (install Helm or omit --validate)"]
    fd, tmp = tempfile.mkstemp(suffix=".yaml")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            yaml.dump(values, fh)
        proc = subprocess.run(
            ["helm", "template", str(chart_dir), "-f", tmp],
            capture_output=True, text=True,
        )
        return [] if proc.returncode == 0 else [ln for ln in proc.stderr.splitlines() if ln.strip()]
    finally:
        os.unlink(tmp)


def process_file(path: Path, args, explicit: bool = False) -> bool:
    yaml = _new_yaml()
    original = path.read_text(encoding="utf-8")
    try:
        docs = list(yaml.load_all(original))
    except Exception as exc:  # noqa: BLE001
        print(f"\n=== {path} ===\n  ERROR parsing YAML: {exc}", file=sys.stderr)
        return False

    report = Report(str(path))
    changed = False
    for doc in docs:
        if migrate_doc(doc, args, report, allow_bare=explicit):
            changed = True

    # Keep batch output focused: only report files that changed (or raised a warning),
    # unless --verbose is given.
    if changed or report.warnings or args.verbose:
        print(report.render())
    if not changed:
        return False

    if args.validate:
        for idx, vals in enumerate(report.targets, 1):
            label = "values" if len(report.targets) == 1 else f"values #{idx}"
            errors = _validate_values(vals, args.chart_dir, yaml)
            if errors:
                print(f"  VALIDATION FAILED ({label}) against {args.chart_dir}:")
                for line in errors[:25]:
                    print(f"    {line}")
            else:
                print(f"  validation OK ({label}) -- renders against {args.chart_dir}")

    new_text = _dump_all(yaml, docs)
    if args.add_schema:
        is_hr = any(isinstance(d, dict) and d.get("kind") == "HelmRelease" for d in docs)
        new_text = _with_schema_modeline(new_text, args.target_version, is_hr)
    if args.show_diff:
        diff = difflib.unified_diff(
            original.splitlines(keepends=True), new_text.splitlines(keepends=True),
            fromfile=str(path), tofile=f"{path} (1.0.0)",
        )
        sys.stdout.writelines(diff)

    if args.write:
        if args.backup:
            path.with_suffix(path.suffix + ".bak").write_text(original, encoding="utf-8")
        path.write_text(new_text, encoding="utf-8")
        print(f"  written: {path}")
    elif args.output_suffix:
        out = path.with_name(path.stem + args.output_suffix)
        out.write_text(new_text, encoding="utf-8")
        print(f"  written: {out}")
    else:
        print("  dry-run: no files written (use --write or --output-suffix)")
    return True


def iter_paths(paths: list[str], recursive: bool, glob: str):
    """Yield (path, explicit) where explicit=True for files named directly on the command
    line and False for files discovered by scanning a directory."""
    for raw in paths:
        p = Path(raw)
        if p.is_dir():
            for f in sorted(p.rglob(glob) if recursive else p.glob(glob)):
                yield f, False
        elif p.is_file():
            yield p, True
        else:
            print(f"skip: {p} not found", file=sys.stderr)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Migrate PWA Helm values from 0.x to 1.0.0.")
    ap.add_argument("paths", nargs="+", help="files and/or directories")
    ap.add_argument("-w", "--write", action="store_true", help="write changes back in place")
    ap.add_argument("--backup", action="store_true", help="with --write, keep a .bak of the original")
    ap.add_argument("-o", "--output-suffix", help="write to <stem><suffix> instead of in place")
    ap.add_argument("-r", "--recursive", action="store_true", help="recurse into directories")
    ap.add_argument("--glob", default="*.y*ml", help="file pattern for directories (default *.y*ml)")
    ap.add_argument("--target-version", default=DEFAULT_TARGET_VERSION, help="chart version to set")
    ap.add_argument("--no-lift-env", action="store_true", help="keep ICM_BASE_URL_SSR/ALLOWED_HOSTS in app.env")
    ap.add_argument("--show-diff", action="store_true", help="print a unified diff of changes")
    ap.add_argument("-v", "--verbose", action="store_true", help="also report files that were skipped/unchanged")
    ap.add_argument("--validate", action="store_true",
                    help="after migrating, render the result against the chart to check the 1.0.0 schema (needs helm)")
    ap.add_argument("--chart-dir", type=Path, default=_chart_dir_default(),
                    help="chart directory used by --validate (default: the pwa chart next to this script)")
    ap.add_argument("--add-schema", action="store_true",
                    help="prepend a yaml-language-server $schema modeline (flux/values schema, pinned to --target-version)")
    args = ap.parse_args(argv)

    total = changed = 0
    for path, explicit in iter_paths(args.paths, args.recursive, args.glob):
        total += 1
        if process_file(path, args, explicit):
            changed += 1

    print(f"\nSummary: migrated {changed} of {total} scanned file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
