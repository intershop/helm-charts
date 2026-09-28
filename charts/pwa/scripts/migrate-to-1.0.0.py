#!/usr/bin/env python3
"""Migrate Intershop PWA Helm values from the 0.x layout to the 1.0.0 layout.

Flux ``HelmRelease`` documents are migrated when their chart is ``pwa-main`` (the tool
transforms ``spec.values`` and bumps ``spec.chart.spec.chart`` -> ``pwa`` and ``version``).
Chart-less ``HelmRelease`` documents (e.g. Kustomize strategic-merge patches that only carry
``spec.values``) are migrated too, but only when the values contain the PWA-specific ``cache``
or ``upstream`` block, so other charts' chart-less patches are never touched. Their values are
rewritten with no chart/version bump, and such fragments are excluded from --validate/--add-schema.
A bare 0.x values file is migrated too, but only when passed **explicitly as an input file** --
directory batch scans (``-r``) process HelmReleases only, so mixed trees stay safe. Any other
document is left untouched. Comments/formatting are preserved via ruamel.yaml round-tripping.

Supported sources are pwa-main 0.7.0 and later. The mapping mirrors charts/pwa/docs/migrate-to-1.0.0.md:
  * top-level SSR keys        -> app.<key>
  * environment               -> app.env
  * cache.*                   -> proxy.*   (cache.extraEnvVars -> proxy.env)
  * upstream.icmBaseURL       -> config.icmBaseUrl (required)
  * top-level allowedHosts    -> config.allowedHosts
  * ICM_BASE_URL_SSR/ALLOWED_HOSTS env entries -> config.icmBaseUrlSsr/allowedHosts
  * upstream.cdnPrefixURL, cache.prefetch, cache.init, calculated -> removed
  Older (pre-0.13.0) layouts:
  * <=0.7 ingress (annotations/hosts/paths/tls) + ingresssplit -> ingress.instances.{ingress,ingresssplit}
  * <=0.9 hybrid.backend, 0.10+ hybrid.icmInternalURL           -> config.icmBaseUrlSsr (when hybrid enabled)
  * 0.11 cache.reset.image "repo:tag" string                    -> proxy.reset.image.{repository,tag}
  * cache.init.enabled: false                                   -> proxy.reset.enabled: false

Directory mode also folds standalone ``HorizontalPodAutoscaler`` manifests into the matching
HelmRelease's ``spec.values.<tier>.autoscaling`` (tier from the HPA's scaleTargetRef name:
``*-pwa-main``/``*-pwa-app`` -> app, ``*-pwa-main-cache``/``*-pwa-proxy`` -> proxy) and removes
the now-redundant manifest (and its kustomization.yaml entry). Applied only with --write.

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
# dropped in 1.0.0; cache.enabled was already ignored since 0.7.0 (the proxy is always deployed)
CACHE_REMOVE = {"enabled", "prefetch", "init", "nameOverride", "fullnameOverride"}
REMOVED_TOP = ["calculated"]                    # top-level keys dropped in 1.0.0
ENV_TO_CONFIG = {"ICM_BASE_URL_SSR": "icmBaseUrlSsr", "ALLOWED_HOSTS": "allowedHosts"}
# 0.x top-level keys that are still valid at the top level in 1.0.0.
KEEP_TOP = {"nameOverride", "fullnameOverride", "hybrid", "imagePullSecrets", "ingress", "config", "app", "proxy"}
MIN_SOURCE_VERSION = (0, 7, 0)
# <=0.7.x flat ingress layout (replaced by ingress.instances in 0.8.0).
LEGACY_INGRESS_KEYS = ("annotations", "hosts", "tls")
# 0.x default ingress.className; 1.0.0 changed the default to ingress-haproxy.
LEGACY_INGRESS_CLASS = "nginx"


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


def _version_tuple(ver):
    m = re.match(r"\s*v?(\d+)\.(\d+)\.(\d+)", str(ver or ""))
    return tuple(int(x) for x in m.groups()) if m else None


def _truthy(value) -> bool:
    # Unresolved Flux substitutions (e.g. "${ingress_enabled}") count as set.
    return value not in (False, None, "", "false", "False")


def _is_legacy_ingress(node) -> bool:
    return isinstance(node, dict) and "instances" not in node and any(k in node for k in LEGACY_INGRESS_KEYS)


def _legacy_ingress_instance(src: dict, label: str, name: str, report: Report) -> CommentedMap:
    """Pop the <=0.7 annotations/hosts/tls of `src` and return them as a 1.0.0 ingress instance.

    The TLS list becomes one instance-level tlsSecretName (the secret covering most hosts, or a
    host-less entry) plus per-host tlsSecretName overrides; per-host paths are dropped because
    0.8.0+ always routes `/` (ImplementationSpecific).
    """
    dst = f"ingress.instances.{name}"
    inst = CommentedMap()
    annotations = src.pop("annotations", None)
    hosts = src.pop("hosts", None) or []
    tls = src.pop("tls", None) or []
    host_names = [h.get("host") for h in hosts if isinstance(h, dict)]

    secret_of: dict = {}
    wildcard = None
    for entry in tls:
        secret = entry.get("secretName") if isinstance(entry, dict) else None
        if not secret:
            report.warn(f"{label}.tls entry without secretName dropped")
            continue
        tls_hosts = entry.get("hosts") or []
        if not tls_hosts:
            wildcard = wildcard or secret
        for host in tls_hosts:
            if host not in host_names:
                report.warn(f"{label}.tls host '{host}' has no matching {label}.hosts entry; dropped")
            elif secret_of.setdefault(host, secret) != secret:
                report.warn(f"{label}.tls host '{host}' is listed for several secrets; kept '{secret_of[host]}'")
    used = list(secret_of.values())
    root = wildcard or (max(dict.fromkeys(used), key=used.count) if used else None)

    dropped_paths = False
    for entry in hosts:
        if not isinstance(entry, dict):
            continue
        host = entry.get("host")
        paths = entry.pop("paths", None)
        if paths is not None:
            dropped_paths = True
            if len(paths) > 1 or any(
                not isinstance(p, dict) or p.get("path", "/") != "/"
                or p.get("pathType", "ImplementationSpecific") != "ImplementationSpecific" for p in paths
            ):
                report.warn(f"{label} host '{host}': custom paths dropped -- 1.0.0 always routes '/' (ImplementationSpecific)")
        secret = secret_of.get(host)
        if secret and secret != root:
            entry["tlsSecretName"] = secret
        elif secret is None and root and not wildcard:
            report.warn(f"{label} host '{host}' had no TLS in 0.x; 1.0.0 serves it with tlsSecretName '{root}'")
        for extra in [k for k in entry if k not in ("host", "tlsSecretName")]:
            report.warn(f"{label} host '{host}': key '{extra}' has no 1.0.0 mapping; left unchanged -- review manually")

    if annotations:
        inst["annotations"] = annotations
        report.map(f"{label}.annotations", f"{dst}.annotations")
    if root:
        inst["tlsSecretName"] = root
    if tls:
        report.map(f"{label}.tls", f"{dst}.tlsSecretName (+ per-host tlsSecretName)")
    if hosts:
        inst["hosts"] = hosts
        report.map(f"{label}.hosts", f"{dst}.hosts")
    if dropped_paths:
        report.remove(f"{label}.hosts[].paths")
    return inst


def _migrate_ingress(values: dict, report: Report, fragment: bool) -> None:
    """Convert the <=0.7 `ingress`/`ingresssplit` layout to `ingress.instances` and pin the 0.x
    default className. `fragment` (chart-less patch) skips defaults the base release decides."""
    ing = values.get("ingress")
    has_split = "ingresssplit" in values
    split = values.pop("ingresssplit") if has_split else None
    legacy = _is_legacy_ingress(ing)

    if legacy or has_split:
        if not isinstance(ing, dict):
            ing = CommentedMap()
            values["ingress"] = ing
        instances = ing.get("instances") if isinstance(ing.get("instances"), dict) else CommentedMap()
        primary_on = _truthy(ing.get("enabled", legacy))   # 0.7.x default: enabled
        split_on = isinstance(split, dict) and _truthy(split.get("enabled", False))

        if legacy:
            if fragment or primary_on or not split_on:
                instances["ingress"] = _legacy_ingress_instance(ing, "ingress", "ingress", report)
            else:
                for key in LEGACY_INGRESS_KEYS:
                    ing.pop(key, None)
                report.remove("ingress.annotations/hosts/tls (ingress disabled)")
                report.warn("ingress was disabled but ingresssplit enabled; 1.0.0 has one ingress.enabled "
                            "switch for all instances, so only the ingresssplit instance is kept")
        if isinstance(split, dict) and (fragment or split_on):
            instances["ingresssplit"] = _legacy_ingress_instance(split, "ingresssplit", "ingresssplit", report)
            split_class = split.get("className")
            if split_class is not None:
                if "className" not in ing:
                    ing["className"] = split_class
                    report.map("ingresssplit.className", "ingress.className")
                elif ing["className"] != split_class:
                    report.warn(f"ingresssplit.className '{split_class}' differs from ingress.className "
                                f"'{ing['className']}'; 1.0.0 uses one className for all instances")
            for extra in [k for k in split if k not in ("enabled", "className")]:
                report.warn(f"ingresssplit.{extra} has no 1.0.0 mapping; dropped")
        elif has_split:
            report.remove("ingresssplit (disabled)" if isinstance(split, dict) else "ingresssplit")

        if not fragment:
            enabled = primary_on or split_on
            if "enabled" not in ing:
                ing.insert(0, "enabled", enabled)
                src = "ingress.enabled (unset; 0.7.x default true)" if legacy else "ingress.enabled (unset)"
                report.map(src, f"ingress.enabled: {str(enabled).lower()}")
            elif _truthy(ing["enabled"]) != enabled:
                ing["enabled"] = enabled
                report.map("ingress.enabled", f"ingress.enabled: {str(enabled).lower()}")
        if instances and "instances" not in ing:
            ing["instances"] = instances
        for extra in [k for k in ing if k not in ("enabled", "className", "instances")]:
            report.warn(f"ingress.{extra} has no 1.0.0 mapping; left unchanged -- review manually")
        if instances:
            report.note("Ingress objects are recreated under new names (<release>-pwa-proxy-<instance>)")

    if not fragment and isinstance(ing, dict) and _truthy(ing.get("enabled")) and "className" not in ing:
        ing.insert(list(ing).index("enabled") + 1, "className", LEGACY_INGRESS_CLASS)
        report.map(f"ingress.className (unset; 0.x default {LEGACY_INGRESS_CLASS})",
                   f"ingress.className: {LEGACY_INGRESS_CLASS}")


def _legacy_hybrid_backend_url(backend, release: str) -> str:
    """SSR_HYBRID_BACKEND as rendered by the <=0.9 `pwa-main.hybridname` helper."""
    backend = backend if isinstance(backend, dict) else {}
    service = backend.get("service") or "icm-web"
    base = release if service in release else f"{release}-{service}"
    return f"https://{base[:63].rstrip('-')}-wa:{backend.get('port') or 443}"


def _migrate_hybrid(values: dict, config: CommentedMap, report: Report, release, source_version) -> None:
    """Map the 0.x hybrid backend URL (SSR_HYBRID_BACKEND) to config.icmBaseUrlSsr."""
    hybrid = values.get("hybrid")
    if not isinstance(hybrid, dict):
        return
    enabled = _truthy(hybrid.get("enabled"))
    url = src = None
    if "icmInternalURL" in hybrid:
        internal = hybrid.pop("icmInternalURL")
        if enabled and internal:
            url, src = internal, "hybrid.icmInternalURL"
        else:
            report.remove("hybrid.icmInternalURL")
    # <=0.9.x always derived the backend from the release name (hybrid.backend defaulted to {}).
    pre_010 = source_version is not None and source_version < (0, 10, 0)
    if "backend" in hybrid or (enabled and pre_010 and url is None):
        backend = hybrid.pop("backend", None)
        if enabled and url is None:
            if release:
                url, src = _legacy_hybrid_backend_url(backend, release), "hybrid.backend"
            else:
                report.warn("hybrid.backend: release name unknown -- set config.icmBaseUrlSsr to "
                            "https://<release>-<backend.service|icm-web>-wa:<backend.port|443> manually")
        if backend is not None and src != "hybrid.backend":
            report.remove("hybrid.backend")
    if url is None:
        return
    if config.get("icmBaseUrlSsr") not in (None, "") and config["icmBaseUrlSsr"] != url:
        report.warn(f"{src} ('{url}') differs from config.icmBaseUrlSsr; kept config.icmBaseUrlSsr")
        return
    config["icmBaseUrlSsr"] = url
    report.map(src, "config.icmBaseUrlSsr")
    report.warn("config.icmBaseUrlSsr (hybrid backend) also sets ICM_BASE_URL_SSR on app and proxy; "
                "0.x used it only for SSR_HYBRID_BACKEND -- verify")


def _split_image_ref(ref: str):
    name, sep, tag = ref.rpartition(":")
    if sep and "/" not in tag and "@" not in ref:
        return name, tag
    return ref, None


def migrate_values(values: CommentedMap, report: Report, lift_env: bool = True, release=None,
                   source_version=None, fragment: bool = False) -> bool:
    """Transform a 0.x values mapping in place. Returns True if anything changed.

    `release` (Helm release name) and `source_version` (0.x chart version tuple) are only needed
    for the <=0.9 hybrid backend; `fragment` marks a chart-less patch (no default injection).
    """
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
        init_off = (isinstance(cache, dict) and isinstance(cache.get("init"), dict)
                    and cache["init"].get("enabled") is False)
        if isinstance(cache, dict):
            for ck in list(cache.keys()):
                if ck in CACHE_REMOVE:
                    if ck == "enabled" and not _truthy(cache[ck]):
                        report.warn("cache.enabled: false was ignored since 0.7.0; the proxy tier is always deployed")
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
        # 0.12.0 replaced the init container with the reset job; keep an opted-out cache flush off.
        if init_off and not (isinstance(proxy.get("reset"), dict) and "enabled" in proxy["reset"]):
            _ensure(proxy, "reset")["enabled"] = False
            report.map("cache.init.enabled: false", "proxy.reset.enabled: false")
        reset = proxy.get("reset")
        if isinstance(reset, dict) and isinstance(reset.get("image"), str):
            repository, tag = _split_image_ref(reset["image"])
            image = CommentedMap(repository=repository)
            if tag:
                image["tag"] = tag
            reset["image"] = image
            report.map("cache.reset.image (0.11 'repo:tag' string)", "proxy.reset.image.repository/tag")

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

    _migrate_hybrid(values, config, report, release, source_version)
    _migrate_ingress(values, report, fragment)

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
    markers = {"upstream", "cache", "environment", "ingresssplit", *SSR_KEYS}
    return isinstance(doc, dict) and any(k in doc for k in markers) and "proxy" not in doc


def _is_0x_pwa_patch(values) -> bool:
    """Strict marker for a chart-less PWA values patch (e.g. a Kustomize version overlay).

    Requires the nginx ``cache`` block or the ``upstream`` block -- both are PWA-0.x-specific and,
    unlike generic keys such as ``image``/``replicaCount``, do not appear in other charts' patches.
    This keeps a batch scan from touching other charts' chart-less HelmRelease patches.
    """
    if not isinstance(values, dict) or "proxy" in values:
        return False
    return any(isinstance(values.get(k), dict) for k in ("cache", "upstream", "ingresssplit"))


def _flux_release_name(doc: dict, spec: dict):
    """Helm release name of a Flux HelmRelease: spec.releaseName or [<targetNamespace>-]<name>."""
    if spec.get("releaseName"):
        return str(spec["releaseName"])
    meta = doc.get("metadata")
    name = meta.get("name") if isinstance(meta, dict) else None
    if not name:
        return None
    target_ns = spec.get("targetNamespace")
    return f"{target_ns}-{name}" if target_ns else str(name)


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
    if not isinstance(spec, dict):
        report.note("HelmRelease without spec -- skipped")
        return False
    chart = spec.get("chart")
    chartspec = chart.get("spec") if isinstance(chart, dict) else None
    name = chartspec.get("chart") if isinstance(chartspec, dict) else None
    values = spec.get("values")

    if name == MIGRATABLE_CHART:
        chartspec["chart"] = NEW_CHART_NAME
        report.map(f"chart: {MIGRATABLE_CHART}", f"chart: {NEW_CHART_NAME}")
        ver = str(chartspec.get("version", ""))
        source_version = _version_tuple(ver)
        if source_version is not None and source_version < MIN_SOURCE_VERSION:
            report.warn(f"source chart version {ver} is older than 0.7.0 and not supported -- review the result manually")
        if ver.startswith("0."):
            chartspec["version"] = args.target_version
            report.map(f"version: {ver}", f"version: {args.target_version}")
        if "valuesFrom" in spec:
            report.warn("spec.valuesFrom present -- external values are NOT migrated by this tool")
        if isinstance(values, dict):
            migrate_values(values, report, lift_env=not args.no_lift_env,
                           release=_flux_release_name(doc, spec), source_version=source_version)
            report.targets.append(values)
        return report.changed

    # Chart-less HelmRelease -- e.g. a Kustomize strategic-merge patch that only overrides
    # spec.values. There is no chart to bump, but the values may still use the 0.x layout, so
    # migrate them in place. It is a fragment (not independently schema-valid), so it is left
    # out of the --validate / --add-schema targets.
    if name is None and _is_0x_pwa_patch(values):
        migrate_values(values, report, lift_env=not args.no_lift_env, fragment=True)
        report.note("chart-less HelmRelease patch: migrated spec.values only (fragment)")
        return report.changed

    report.note(f"HelmRelease chart is '{name}', not '{MIGRATABLE_CHART}' -- skipped")
    return False


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


def _starts_with_doc_marker(text: str) -> bool:
    """Whether the YAML stream starts with an explicit `---` (skipping leading comments/blanks)."""
    for line in text.splitlines():
        stripped = line.strip()
        if stripped == "" or stripped.startswith("#"):
            continue
        return stripped == "---"
    return False


def _with_pre_doc_comments(original: str, dumped: str) -> str:
    """Re-prepend comment lines that preceded the first `---` (ruamel drops them on round-trip)."""
    head: list[str] = []
    for line in original.splitlines():
        stripped = line.strip()
        if stripped == "---":
            break
        if stripped and not stripped.startswith("#"):
            return dumped
        head.append(line)
    else:
        return dumped
    while head and not head[-1].strip():
        head.pop()
    if not head or dumped.startswith(head[0]):
        return dumped
    return "\n".join(head) + "\n" + dumped


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
    body = [ln for ln in text.split("\n") if not re.match(r"\s*#+\s*yaml-language-server\s*:", ln)]
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


# --- HPA folding (folder mode only) -----------------------------------------
# In a GitOps tree, projects often keep standalone HorizontalPodAutoscaler manifests next
# to the HelmRelease. The 1.0.0 chart configures autoscaling via values instead, so fold
# each HPA into its HelmRelease's spec.values.<tier>.autoscaling and drop the manifest.
HPA_KIND = "HorizontalPodAutoscaler"

# An HPA manifest is routed by its FILE NAME to the sibling HelmRelease in the same
# directory: "<release>[-pwa]-hpa-<suffix>.yaml" -> "<release>.yaml". Routing by release
# NAME across the tree is unsafe -- another chart's HelmRelease (e.g. icm) may share the
# same release name and wrongly receive the config.
HPA_FILE_RE = re.compile(r"^(?P<base>.+?)(?:-pwa)?-hpa-(?P<suffix>[^.]+)$", re.IGNORECASE)

# HPA file-name suffix -> chart tier.
HPA_SUFFIX_TIER = {"ssr": "app", "nginx": "proxy", "cache": "proxy"}

# scaleTargetRef.name suffix -> tier, used only as a fallback when the file-name suffix is
# unfamiliar. Most specific first so "-pwa-main-cache" wins over "-pwa-main".
HPA_TARGET_SUFFIXES = [
    ("-pwa-main-cache", "proxy"),
    ("-pwa-proxy", "proxy"),
    ("-pwa-cache", "proxy"),
    ("-pwa-main", "app"),
    ("-pwa-app", "app"),
]


def _hpa_tier_from_scale_ref(scale_name: str):
    """Tier from a scaleTargetRef name, or None. Fallback when the file-name suffix is unknown."""
    for suffix, tier in HPA_TARGET_SUFFIXES:
        if scale_name.endswith(suffix):
            return tier
    return None


def _pwa_helmrelease_doc(docs):
    """Return the first PWA (chart pwa/pwa-main) HelmRelease document in a file, or None."""
    for doc in docs:
        if not (isinstance(doc, dict) and doc.get("kind") == "HelmRelease"):
            continue
        spec = doc.get("spec")
        chart_spec = spec.get("chart") if isinstance(spec, dict) else None
        inner = chart_spec.get("spec") if isinstance(chart_spec, dict) else None
        chart = inner.get("chart") if isinstance(inner, dict) else None
        if chart in (NEW_CHART_NAME, MIGRATABLE_CHART):
            return doc
    return None


def _copy_eol_comment(src, src_key, dst, dst_key) -> None:
    """Move an end-of-line comment from src[src_key] to dst[dst_key] (best-effort).

    Lets the arithmetic comment on an HPA's averageUtilization survive the collapse into
    the targetCPU/MemoryUtilizationPercentage shortcut.
    """
    src_ca = getattr(src, "ca", None)
    token = src_ca.items.get(src_key) if src_ca is not None else None
    eol = token[2] if token else None
    if eol is not None:
        dst.ca.items[dst_key] = [None, None, eol, None]


def _hpa_autoscaling(spec) -> CommentedMap:
    """Build a chart `autoscaling` values block from a HorizontalPodAutoscaler spec.

    Standard CPU/memory Resource-utilization metrics become the targetCPU/Memory shortcuts
    (carrying any end-of-line comment); any other metric kind keeps the raw `metrics` list.
    `behavior` passes through verbatim.
    """
    out = CommentedMap()
    out["enabled"] = True
    for key in ("minReplicas", "maxReplicas"):
        if key in spec:
            out[key] = spec[key]
    metrics = spec.get("metrics") or []
    cpu_tgt = mem_tgt = None
    only_resource_util = True
    for metric in metrics:
        res = metric.get("resource") if isinstance(metric, dict) else None
        tgt = res.get("target") if isinstance(res, dict) else None
        if (isinstance(metric, dict) and metric.get("type") == "Resource" and isinstance(tgt, dict)
                and tgt.get("type") == "Utilization" and tgt.get("averageUtilization") is not None
                and res.get("name") in ("cpu", "memory")):
            if res["name"] == "cpu":
                cpu_tgt = tgt
            else:
                mem_tgt = tgt
        else:
            only_resource_util = False
    if metrics and only_resource_util:
        if cpu_tgt is not None:
            out["targetCPUUtilizationPercentage"] = cpu_tgt["averageUtilization"]
            _copy_eol_comment(cpu_tgt, "averageUtilization", out, "targetCPUUtilizationPercentage")
        if mem_tgt is not None:
            out["targetMemoryUtilizationPercentage"] = mem_tgt["averageUtilization"]
            _copy_eol_comment(mem_tgt, "averageUtilization", out, "targetMemoryUtilizationPercentage")
    elif metrics:
        out["metrics"] = metrics  # custom/external/object metrics -> keep the list verbatim
    if "behavior" in spec:
        out["behavior"] = spec["behavior"]
    return out


def fold_hpas_in_directory(directory: Path, args, report: Report) -> int:
    """Fold standalone HPA manifests into their sibling PWA HelmRelease.

    Each HPA file is routed by name -- "<release>[-pwa]-hpa-<suffix>.yaml" -> "<release>.yaml"
    in the same directory -- and only when that sibling is a PWA HelmRelease. Returns the
    number folded. Applies changes only with --write; otherwise reports the plan (dry-run).
    """
    yaml = _new_yaml()
    files = sorted(directory.rglob(args.glob) if args.recursive else directory.glob(args.glob))
    loaded: dict = {}
    originals: dict = {}
    for f in files:
        try:
            text = f.read_text(encoding="utf-8")
            loaded[f] = list(yaml.load_all(text))
            originals[f] = text
        except Exception:  # noqa: BLE001
            continue

    write_docs: dict = {}
    delete_files: list = []
    folded = 0

    for f, docs in loaded.items():
        if not any(isinstance(d, dict) and d.get("kind") == HPA_KIND for d in docs):
            continue
        match = HPA_FILE_RE.match(f.stem)
        if not match:
            report.warn(f"{f.name}: does not match '<release>-hpa-<tier>' naming; left as-is")
            continue
        base, suffix = match.group("base"), match.group("suffix")
        file_tier = HPA_SUFFIX_TIER.get(suffix.lower())

        # Route to the sibling HelmRelease file of the same name in the same directory.
        target_file = next(
            (f.with_name(base + ext) for ext in (".yaml", ".yml") if f.with_name(base + ext) in loaded),
            None,
        )
        if target_file is None:
            report.warn(f"{f.name}: no sibling HelmRelease '{base}.yaml'; left as-is")
            continue
        hr_doc = _pwa_helmrelease_doc(loaded[target_file])
        if hr_doc is None:
            report.warn(f"{f.name}: {target_file.name} is not a PWA HelmRelease; left as-is")
            continue

        keep: list = []
        for doc in docs:
            if not (isinstance(doc, dict) and doc.get("kind") == HPA_KIND):
                keep.append(doc)
                continue
            spec = doc.get("spec") if isinstance(doc.get("spec"), dict) else {}
            tier = file_tier or _hpa_tier_from_scale_ref(str((spec.get("scaleTargetRef") or {}).get("name", "")))
            if tier is None:
                report.warn(f"{f.name}: cannot determine tier from suffix '{suffix}'; left as-is")
                keep.append(doc)
                continue
            values = _ensure(hr_doc.setdefault("spec", CommentedMap()), "values")
            tier_map = _ensure(values, tier)
            if "autoscaling" in tier_map:
                report.warn(f"{target_file.name}: {tier}.autoscaling already set; left {f.name} as-is")
                keep.append(doc)
                continue
            tier_map["autoscaling"] = _hpa_autoscaling(spec)
            report.map(f"{f.name}", f"{target_file.name}: spec.values.{tier}.autoscaling")
            write_docs[target_file] = loaded[target_file]
            folded += 1
        if len(keep) != len(docs):
            if keep:
                write_docs[f] = keep
            else:
                delete_files.append(f)

    if folded == 0:
        if report.warnings or args.verbose:
            print(report.render())
        return 0

    # Drop each deleted HPA file from the kustomization.yaml in its own directory.
    deleted_by_dir: dict = {}
    for f in delete_files:
        deleted_by_dir.setdefault(f.parent, set()).add(f.name)
    for kf in [p for p in loaded if p.name in ("kustomization.yaml", "kustomization.yml")]:
        names = deleted_by_dir.get(kf.parent)
        if not names:
            continue
        for doc in loaded[kf]:
            res = doc.get("resources") if isinstance(doc, dict) else None
            if isinstance(res, list) and any(str(r) in names for r in res):
                res[:] = [r for r in res if str(r) not in names]
                write_docs[kf] = loaded[kf]
                report.map(f"{kf.name}: resources", f"removed {', '.join(sorted(names))}")

    print(report.render())
    if not args.write:
        for path in sorted(write_docs, key=str):
            print(f"  would update: {path}")
        for path in delete_files:
            print(f"  would remove: {path}")
        print("  dry-run: no files written (use --write to apply HPA folding)")
        return folded

    for path, pdocs in write_docs.items():
        yaml.explicit_start = _starts_with_doc_marker(originals.get(path, "")) if len(pdocs) <= 1 else True
        text = _with_pre_doc_comments(originals.get(path, ""), _dump_all(yaml, pdocs))
        if args.backup:
            path.with_suffix(path.suffix + ".bak").write_text(originals[path], encoding="utf-8")
        path.write_text(text, encoding="utf-8")
        print(f"  updated: {path}")
    for path in delete_files:
        path.unlink()
        print(f"  removed: {path}")
    return folded


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

    # Preserve the original document-start style: don't inject a leading `---` into a single-doc
    # file that didn't have one. Multi-doc streams keep the markers (needed as separators).
    if len(docs) <= 1:
        yaml.explicit_start = _starts_with_doc_marker(original)

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

    new_text = _with_pre_doc_comments(original, _dump_all(yaml, docs))
    if args.add_schema and report.targets:
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

    # Folder mode only: fold standalone HPA manifests into their HelmRelease's values.
    hpa_folded = 0
    for raw in args.paths:
        p = Path(raw)
        if p.is_dir():
            hpa_folded += fold_hpas_in_directory(p, args, Report(f"HPA folding: {p}"))

    print(f"\nSummary: migrated {changed} of {total} scanned file(s).")
    if hpa_folded:
        print(f"Folded {hpa_folded} HorizontalPodAutoscaler(s) into HelmRelease values.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
