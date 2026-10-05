"""Fixture-based tests for the 0.x -> 1.0.0 PWA values migration script.

The migration script is the sanctioned upgrade route for every consumer, and
`ct install --upgrade` skips upgrade testing across a major version bump
(0.13.0 -> 1.0.0), so these tests are the coverage for that highest-risk path.

Each fixture pairs a 0.x input with its expected 1.0.0 output; the assertions
compare parsed data structures (order/comment insensitive), not rendered text.
"""
from __future__ import annotations

import argparse
import importlib.util
import shutil
from pathlib import Path

import pytest
from ruamel.yaml import YAML

HERE = Path(__file__).resolve().parent
SCRIPT = HERE.parent / "migrate-to-1.0.0.py"
FIXTURES = HERE / "fixtures"


def _load_module():
    spec = importlib.util.spec_from_file_location("migrate_pwa", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


migrate = _load_module()


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    return y


def _load(path: Path):
    return _yaml().load(path.read_text(encoding="utf-8"))


def _load_all(path: Path):
    return list(_yaml().load_all(path.read_text(encoding="utf-8")))


def _plain(node):
    """Recursively convert ruamel nodes to plain dict/list/scalars for comparison."""
    if isinstance(node, dict):
        return {k: _plain(v) for k, v in node.items()}
    if isinstance(node, list):
        return [_plain(v) for v in node]
    return node


def _args(no_lift_env: bool = False, target_version: str = "1.0.0") -> argparse.Namespace:
    return argparse.Namespace(no_lift_env=no_lift_env, target_version=target_version)


# --- bare values files -------------------------------------------------------

@pytest.mark.parametrize("name", ["bare-values", "bare-env-lift"])
def test_bare_values_migration(name):
    values = _load(FIXTURES / name / "input.yaml")
    expected = _plain(_load(FIXTURES / name / "expected.yaml"))

    changed = migrate.migrate_values(values, migrate.Report(name))

    assert changed is True
    assert _plain(values) == expected


def test_bare_env_lift_disabled():
    values = _load(FIXTURES / "bare-env-lift" / "input.yaml")
    expected = _plain(_load(FIXTURES / "bare-env-lift" / "expected-no-lift.yaml"))

    migrate.migrate_values(values, migrate.Report("no-lift"), lift_env=False)

    assert _plain(values) == expected


# --- HelmRelease documents ---------------------------------------------------

def test_flux_helmrelease_migration():
    doc = _load(FIXTURES / "flux-helmrelease" / "input.yaml")
    expected = _plain(_load(FIXTURES / "flux-helmrelease" / "expected.yaml"))

    changed = migrate.migrate_doc(doc, _args(), migrate.Report("flux"))

    assert changed is True
    assert _plain(doc) == expected


def test_kustomize_patch_migration():
    doc = _load(FIXTURES / "kustomize-patch" / "input.yaml")
    expected = _plain(_load(FIXTURES / "kustomize-patch" / "expected.yaml"))

    changed = migrate.migrate_doc(doc, _args(), migrate.Report("patch"))

    assert changed is True
    # A chart-less patch keeps its (absent) chart spec: no version bump happened.
    assert _plain(doc) == expected


# --- behavioral guarantees ---------------------------------------------------

def test_migration_is_idempotent():
    values = _load(FIXTURES / "bare-values" / "input.yaml")
    migrate.migrate_values(values, migrate.Report("first"))

    second = migrate.Report("second")
    changed_again = migrate.migrate_values(values, second)

    assert changed_again is False
    assert second.maps == []
    assert second.removed == []


def test_flux_helmrelease_is_idempotent():
    doc = _load(FIXTURES / "flux-helmrelease" / "input.yaml")
    migrate.migrate_doc(doc, _args(), migrate.Report("first"))

    changed_again = migrate.migrate_doc(doc, _args(), migrate.Report("second"))

    assert changed_again is False


def test_removed_keys_are_dropped_and_reported():
    values = _load(FIXTURES / "bare-values" / "input.yaml")
    report = migrate.Report("removed")

    migrate.migrate_values(values, report)

    assert "upstream.cdnPrefixURL" in report.removed
    assert "cache.prefetch" in report.removed
    assert "calculated" in report.removed
    assert "cdnPrefixURL" not in _plain(values).get("config", {})
    assert "prefetch" not in _plain(values).get("proxy", {})
    assert "calculated" not in _plain(values)


def test_chart_managed_env_is_lifted_per_tier():
    values = _yaml().load(
        "environment:\n"
        "  - {name: LOGLEVEL, value: DEBUG}\n"
        "  - {name: LOGFORMAT, value: text}\n"
        "  - {name: METRICS_DETAIL_LEVEL, value: detailed}\n"
        "  - {name: PORT, value: '4200'}\n"
        "  - {name: THEME, value: b2c}\n"
        "cache:\n"
        "  extraEnvVars:\n"
        "    - {name: LOGLEVEL, value: warn}\n"
        "    - {name: LOGFORMAT, value: json}\n"
    )
    report = migrate.Report("managed-env")

    migrate.migrate_values(values, report)

    plain = _plain(values)
    assert plain["app"]["logging"] == {"level": "debug", "format": "text"}
    assert plain["app"]["metrics"] == {"detailLevel": "DETAILED"}
    assert plain["app"]["env"] == [{"name": "THEME", "value": "b2c"}]
    assert plain["proxy"]["logging"] == {"level": "warn", "format": "json"}
    assert "env" not in plain["proxy"]
    assert "app.env[PORT]" in report.removed
    assert not report.warnings


def test_unmappable_managed_env_warns_and_is_kept():
    values = _yaml().load(
        "environment:\n"
        "  - {name: PORT, value: '8080'}\n"
        "cache:\n"
        "  extraEnvVars:\n"
        "    - {name: LOGLEVEL, value: debug}\n"
    )
    report = migrate.Report("unmappable")

    migrate.migrate_values(values, report)

    plain = _plain(values)
    assert "app" not in plain
    assert plain["proxy"]["env"] == [{"name": "LOGLEVEL", "value": "debug"}]
    assert any("PORT" in w and "4200" in w for w in report.warnings)
    assert any("proxy.env[LOGLEVEL]" in w for w in report.warnings)


def test_unknown_top_level_key_warns_and_is_kept():
    values = _load(FIXTURES / "flux-helmrelease" / "input.yaml")["spec"]["values"]
    values["totallyCustom"] = {"keep": True}
    report = migrate.Report("unknown")

    migrate.migrate_values(values, report)

    assert any("totallyCustom" in w for w in report.warnings)
    assert _plain(values)["totallyCustom"] == {"keep": True}


def test_non_pwa_helmrelease_is_untouched():
    doc = _load(FIXTURES / "flux-helmrelease" / "input.yaml")
    doc["spec"]["chart"]["spec"]["chart"] = "some-other-chart"
    before = _plain(doc)

    changed = migrate.migrate_doc(doc, _args(), migrate.Report("other"))

    assert changed is False
    assert _plain(doc) == before


# --- older 0.x layouts (0.7.0 .. 0.12.x) ------------------------------------

def _values(text: str):
    return _yaml().load(text)


def test_flux_helmrelease_0_7_migration():
    doc = _load(FIXTURES / "flux-helmrelease-0.7" / "input.yaml")
    expected = _plain(_load(FIXTURES / "flux-helmrelease-0.7" / "expected.yaml"))

    changed = migrate.migrate_doc(doc, _args(), migrate.Report("flux-0.7"))

    assert changed is True
    assert _plain(doc) == expected


def test_flux_helmrelease_0_7_is_idempotent():
    doc = _load(FIXTURES / "flux-helmrelease-0.7" / "input.yaml")
    migrate.migrate_doc(doc, _args(), migrate.Report("first"))
    values = doc["spec"]["values"]

    second = migrate.Report("second")
    changed_again = migrate.migrate_values(values, second)

    assert changed_again is False
    assert second.warnings == []


def test_legacy_ingress_disabled_split_enabled_keeps_only_split():
    values = _values("""
ingress:
  enabled: false
  hosts: [{host: a.example.com}]
ingresssplit:
  enabled: true
  className: nginx
  hosts: [{host: b.example.com}]
""")
    report = migrate.Report("split-only")

    migrate.migrate_values(values, report)

    ingress = _plain(values)["ingress"]
    assert ingress["enabled"] is True
    assert ingress["className"] == "nginx"
    assert list(ingress["instances"]) == ["ingresssplit"]
    assert any("only the ingresssplit instance" in w for w in report.warnings)


def test_disabled_ingresssplit_is_dropped():
    values = _values("""
ingress:
  hosts: [{host: a.example.com}]
ingresssplit:
  enabled: false
  hosts: [{host: b.example.com}]
""")
    report = migrate.Report("split-off")

    migrate.migrate_values(values, report)

    plain = _plain(values)
    assert "ingresssplit" not in plain
    assert list(plain["ingress"]["instances"]) == ["ingress"]
    assert "ingresssplit (disabled)" in report.removed


def test_legacy_ingress_custom_path_warns():
    values = _values("""
ingress:
  enabled: true
  hosts:
    - host: a.example.com
      paths: [{path: /shop, pathType: Prefix}]
""")
    report = migrate.Report("paths")

    migrate.migrate_values(values, report)

    assert _plain(values)["ingress"]["instances"]["ingress"]["hosts"] == [{"host": "a.example.com"}]
    assert any("custom paths dropped" in w for w in report.warnings)


def test_enabled_ingress_without_class_pins_legacy_default():
    # 0.x defaulted ingress.className to nginx; 1.0.0 defaults to ingress-haproxy.
    values = _values("ingress:\n  enabled: true\n  instances:\n    ingress:\n      hosts: [{host: a.example.com}]\n")

    migrate.migrate_values(values, migrate.Report("class"))

    assert list(_plain(values)["ingress"])[:2] == ["enabled", "className"]
    assert values["ingress"]["className"] == "nginx"


def test_legacy_ingress_in_patch_fragment_injects_no_defaults():
    doc = _values("""
kind: HelmRelease
spec:
  values:
    cache:
      replicaCount: 1
    ingress:
      hosts: [{host: a.example.com, paths: [{path: /}]}]
""")

    migrate.migrate_doc(doc, _args(), migrate.Report("fragment"))

    assert _plain(doc)["spec"]["values"]["ingress"] == {
        "instances": {"ingress": {"hosts": [{"host": "a.example.com"}]}}
    }


def test_hybrid_icm_internal_url_maps_to_config():
    values = _values("hybrid:\n  enabled: true\n  icmInternalURL: https://icm-web-wa:8443\n  pwaExternalPort: 443\n")

    migrate.migrate_values(values, migrate.Report("hybrid"))

    plain = _plain(values)
    assert plain["config"]["icmBaseUrlSsr"] == "https://icm-web-wa:8443"
    assert plain["hybrid"] == {"enabled": True, "pwaExternalPort": 443}


def test_disabled_hybrid_drops_backend_settings():
    values = _values("hybrid:\n  enabled: false\n  backend: {}\n  icmInternalURL: https://x\n")
    report = migrate.Report("hybrid-off")

    migrate.migrate_values(values, report)

    assert _plain(values)["hybrid"] == {"enabled": False}
    assert {"hybrid.backend", "hybrid.icmInternalURL"} <= set(report.removed)
    assert "config" not in _plain(values)


def test_reset_image_string_is_split():
    # 0.11.0 squashed the reset image into one string.
    values = _values("cache:\n  reset:\n    enabled: true\n    image: registry.example.com:5000/utils/kubectl:1.2.3\n")

    migrate.migrate_values(values, migrate.Report("reset"))

    assert _plain(values)["proxy"]["reset"]["image"] == {
        "repository": "registry.example.com:5000/utils/kubectl", "tag": "1.2.3",
    }


def test_disabled_cache_init_disables_reset():
    values = _values("cache:\n  init:\n    enabled: false\n")

    migrate.migrate_values(values, migrate.Report("init"))

    assert _plain(values)["proxy"] == {"reset": {"enabled": False}}


def test_obsolete_cache_enabled_is_dropped():
    # cache.enabled was removed in 0.7.0; proxy.enabled is rejected by the 1.0.0 schema.
    values = _values("cache:\n  enabled: true\n  replicaCount: 1\n")
    report = migrate.Report("cache-enabled")

    migrate.migrate_values(values, report)

    assert _plain(values)["proxy"] == {"replicaCount": 1}
    assert "cache.enabled" in report.removed
    assert report.warnings == []


def test_source_older_than_0_7_warns():
    doc = _load(FIXTURES / "flux-helmrelease" / "input.yaml")
    doc["spec"]["chart"]["spec"]["version"] = "0.6.0"
    report = migrate.Report("old")

    migrate.migrate_doc(doc, _args(), report)

    assert any("older than 0.7.0" in w for w in report.warnings)


# --- folder-mode HPA folding ------------------------------------------------

def _copy_hpa_folder(tmp_path):
    dst = tmp_path / "pwa"
    shutil.copytree(FIXTURES / "hpa-folder", dst)
    return dst


def test_hpa_folding_injects_autoscaling_and_removes_manifests(tmp_path):
    dst = _copy_hpa_folder(tmp_path)

    rc = migrate.main(["-r", "--write", str(dst)])
    assert rc == 0

    # The PWA HPA manifests are removed...
    assert not (dst / "release-live-hpa-ssr.yaml").exists()
    assert not (dst / "release-live-pwa-hpa-nginx.yaml").exists()
    # ...and dropped from the kustomization resource list.
    resources = [str(r) for r in _load(dst / "kustomization.yaml")["resources"]]
    assert "release-live-hpa-ssr.yaml" not in resources
    assert "release-live-pwa-hpa-nginx.yaml" not in resources
    assert "release-live.yaml" in resources

    # The live release gains both tiers' autoscaling (ssr -> app, nginx -> proxy).
    live = _plain(_load(dst / "release-live.yaml"))
    app_as = live["spec"]["values"]["app"]["autoscaling"]
    assert app_as["enabled"] is True
    assert app_as["minReplicas"] == 4
    assert app_as["maxReplicas"] == 16
    assert app_as["targetCPUUtilizationPercentage"] == 1500
    assert app_as["behavior"]["scaleDown"]["stabilizationWindowSeconds"] == 900

    proxy_as = live["spec"]["values"]["proxy"]["autoscaling"]
    assert proxy_as["targetCPUUtilizationPercentage"] == 750
    assert proxy_as["targetMemoryUtilizationPercentage"] == 80


def test_hpa_folding_routes_by_filename_not_release_name(tmp_path):
    # release-icm.yaml shares the release name "demo" with release-live.yaml. Routing by
    # file name (not release name) must keep the pwa HPA out of the icm HelmRelease.
    dst = _copy_hpa_folder(tmp_path)

    migrate.main(["-r", "--write", str(dst)])

    icm = _plain(_load(dst / "release-icm.yaml"))
    assert "autoscaling" not in icm["spec"]["values"].get("app", {})
    assert "autoscaling" not in icm["spec"]["values"].get("proxy", {})


def test_hpa_folding_skips_non_pwa_sibling(tmp_path):
    # An HPA whose sibling HelmRelease is not a PWA chart is left untouched.
    dst = _copy_hpa_folder(tmp_path)

    migrate.main(["-r", "--write", str(dst)])

    assert (dst / "release-icm-hpa-ssr.yaml").exists()
    resources = [str(r) for r in _load(dst / "kustomization.yaml")["resources"]]
    assert "release-icm-hpa-ssr.yaml" in resources


def test_hpa_folding_leaves_other_releases_untouched(tmp_path):
    dst = _copy_hpa_folder(tmp_path)

    migrate.main(["-r", "--write", str(dst)])

    edit = _plain(_load(dst / "release-edit.yaml"))
    assert "autoscaling" not in edit["spec"]["values"].get("app", {})


def test_hpa_folding_preserves_metric_comment(tmp_path):
    # The arithmetic comment on averageUtilization survives the collapse to the shortcut.
    dst = _copy_hpa_folder(tmp_path)

    migrate.main(["-r", "--write", str(dst)])

    text = (dst / "release-live.yaml").read_text(encoding="utf-8")
    assert "targetCPUUtilizationPercentage: 1500 # limits=3000m" in text


def test_hpa_folding_keeps_schema_modeline_before_doc_marker(tmp_path):
    # ruamel drops comments before `---`; the HPA rewrite must keep a leading $schema modeline.
    dst = _copy_hpa_folder(tmp_path)
    live = dst / "release-live.yaml"
    modeline = "# yaml-language-server: $schema=https://example.com/values-flux.schema.json"
    live.write_text(f"{modeline}\n---\n" + live.read_text(encoding="utf-8"), encoding="utf-8")

    migrate.main(["-r", "--write", str(dst)])

    text = live.read_text(encoding="utf-8")
    assert text.startswith(modeline + "\n---\n")
    assert "autoscaling" in text


def test_hpa_folding_is_idempotent(tmp_path):
    dst = _copy_hpa_folder(tmp_path)

    migrate.main(["-r", "--write", str(dst)])
    rc = migrate.main(["-r", "--write", str(dst)])

    assert rc == 0
    live = _plain(_load(dst / "release-live.yaml"))
    assert live["spec"]["values"]["app"]["autoscaling"]["targetCPUUtilizationPercentage"] == 1500


def test_hpa_folding_dry_run_writes_nothing(tmp_path):
    dst = _copy_hpa_folder(tmp_path)

    migrate.main(["-r", str(dst)])

    # Dry-run: manifests stay, no autoscaling injected.
    assert (dst / "release-live-hpa-ssr.yaml").exists()
    live = _plain(_load(dst / "release-live.yaml"))
    assert "autoscaling" not in live["spec"]["values"].get("app", {})

