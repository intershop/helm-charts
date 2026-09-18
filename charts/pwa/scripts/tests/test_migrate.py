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

