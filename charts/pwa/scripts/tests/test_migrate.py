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
