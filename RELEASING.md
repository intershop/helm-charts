# Releasing

This document describes how charts in this repository are versioned, changelogged and
released. The process is automated through GitHub Actions and driven by
[Conventional Commits](https://www.conventionalcommits.org). For the commit-message rules
themselves, see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Branching model

We use an adapted Git Flow:

- **`main`** holds production-ready, released code. It is protected and only changes via pull request.
- **`develop/<team>`** branches (`develop/icm`, `develop/iom`, `develop/pwa`, `develop/common`)
  accumulate not-yet-released work. Each team decides what and when to release from its branch.
- **Feature branches** are opened from a `develop/<team>` branch and merged back into it via PR.

### Keeping develop branches in sync with main

Whenever something is merged into `main`, the [`sync develop with main`](.github/workflows/main-develop-sync.yml)
workflow automatically opens a PR that merges `main` back into every `develop/*` branch. This keeps
released changes (including automatic version bumps of dependent charts) flowing into all team
branches, so manual rebasing across chart branches is no longer required. If the automatic merge
hits a conflict, the workflow fails and the conflict must be resolved on the affected
`develop/<team>` branch by hand.

## How the version is determined

The bump level is derived per chart from the commit messages since the chart's last release tag
(see [CONTRIBUTING.md](./CONTRIBUTING.md) for the authoritative rules):

| Commit signal                                                        | Bump  |
| -------------------------------------------------------------------- | ----- |
| `BREAKING CHANGE:` footer, or `!` in the header (e.g. `feat(icm)!:`) | MAJOR |
| `feat:` / `feat(scope):`                                             | MINOR |
| everything else that touches the chart                               | PATCH |

Only commits that modify files under `charts/<chart>/` count toward that chart's release.

## The release process

Releasing is a manually triggered, automated pipeline. Run it from the `develop/<team>` branch you
want to release.

1. **Trigger** the [`Create Release Branch`](.github/workflows/release-branch.yml) workflow
   (`workflow_dispatch`).
2. **Changed charts are detected** by diffing the branch against `main`.
3. **The semantic version is determined** per chart with
   [`paulhatch/semantic-version`](https://github.com/PaulHatch/semantic-version) using the commit
   signals above.
4. **Versions are bumped** via [`bump-my-version`](https://github.com/callowayproject/bump-my-version)
   (driven by [`.github/callBump2version.py`](.github/callBump2version.py) and each chart's
   `.bumpversion.toml`). Charts that embed another chart as a dependency are bumped automatically —
   e.g. bumping `icm-as` also bumps `icm`, `icm-test`, `icm-job-test` and `icm-replication-test`.
   The dependency map lives in `callBump2version.py`. The `iom` chart is excluded (it does not use
   `bump-my-version`) and is versioned separately.
5. **The changelog is updated** per chart with
   [`git-chglog`](https://github.com/git-chglog/git-chglog) using the shared config in
   [`.chglog/`](.chglog). Only the **new version's** section is generated and **prepended** to the
   chart's existing `CHANGELOG.md`, so earlier sections (and any manual corrections) are kept
   verbatim. `RELEASE_NOTES.md` is overwritten with just that newest section (it is the body of the
   published release). Because history is preserved in the file, the changelog is not fully
   re-derived from git on every release.
6. **A release PR** (`release/<branch>` → `main`) is opened with the version bumps and generated
   changelogs.
7. **On merge into `main`**, the [`Release Charts`](.github/workflows/release-charts.yml) workflow
   packages and publishes each chart with
   [`helm/chart-releaser-action`](https://github.com/helm/chart-releaser-action), creating a GitHub
   release and a `<chart>-<version>` tag and using the chart's `RELEASE_NOTES.md` as the release body.
8. **`main` is synced back** into the `develop/*` branches (see above).

## Tag scheme

Each chart is tagged independently as `<chart>-<semver>`, e.g. `icm-as-3.0.0` or `pwa-1.0.0`.

## Notes

- New chart versions do not need to be edited by hand; the release pipeline bumps `Chart.yaml`
  (and related references) via each chart's `.bumpversion.toml`.
- `git-chglog` reads commit types and the `BREAKING CHANGE:` footer from `.chglog/config.yml`; the
  `!` shorthand bumps the version and renders the commit under its type, but only the footer adds a
  dedicated **BREAKING CHANGE** section to the changelog.
