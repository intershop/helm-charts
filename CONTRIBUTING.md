# Contributing to the Intershop Helm Charts

Thank you for your interest in the Intershop helm-chart project.

We welcome any kind of contribution.

## Code of Conduct

We have adopted the [Contributor Covenants](https://www.contributor-covenant.org/) Code of Conduct and we expect project participants to adhere to it. Please read and follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

## Non-Code Contributions

You can contribute to the project without being a software developer. You can help by improving the documentation or analyzing the nature of an issue.

Have feedback? Please send it to devcommunity@intershop.com

## Contributor License Agreement

When you contribute, be aware that your contribution is covered by the same [license](./LICENSE) as the whole project. To contribute, you must agree to the [Contributor License Agreement](./INTERSHOP_CLA.md). If you are an employee of a company, we also need approval from your company that you are authorized to do so. This is mainly to protect you as an employee.

Please print the contributor license agreement and send it to devcommunity@intershop.de.

It is sufficient to do this when you are about to submit your first pull request.

If you have any questions feel free, to also send them to devcommunity@intershop.de.

## Contribution Process

1. Fork the repository.
2. Use the appropriate `develop/<team>` branch as base for your feature branch. See [Releasing](./RELEASING.md).
3. Work on changes.
4. Comment the changes.
5. Check whether the changes comply with the the rules (design etc.).
6. Commit changes according to our Commit Message Guidelines.
7. Create a pull request into the `develop/<team>` base branch.
8. Add as much information as needed.
9. Reference the solved issue.
10. Wait for the review.
11. The pull request is approved, denied (with explanation) or sent back for further information.
12. We are trying to react as fast as possible to pull requests, issues, feedback and any other community interaction. However, we cannot guarantee a particular timeframe for every answer. We hope you understand and apologize for any inconveniences.
13. If the pull request is approved, the changes shall be merged via squash commit to improve commit history readability.

## Commit Message Guidelines

In general, we comply with the rules and formats of [Conventional Commits](https://www.conventionalcommits.org).
These rules are essential to our automated release process and the later rollout of a helm chart. Commit messages will be used to determine the new semantic version and shall help updating existing projects.

Some rules to be emphasized for chart related commits:

- To mark a _MAJOR_ (breaking) change, add a `BREAKING CHANGE:` footer to the commit body while keeping a normal `feat`/`fix` header. The footer both triggers the major version bump and adds a dedicated **BREAKING CHANGE** section to the generated changelog. The `!` shorthand in the header (e.g. `feat(icm)!:`) also triggers the major bump and the commit still appears under its type, but only the footer adds the dedicated **BREAKING CHANGE** section, so prefer the footer.
- A commit message starting with `feat(icm):` (or e.g.: `feat(pwa):`) will get a _MINOR_ change.
- The rest will be _PATCH_.

Please also enhance your commit message with an existing **GitHub issue number**, where detailed information could be found. Github will later on link the commit to the issue ticket automatically.

Here is a sample commit message: `feat(icm): my short commit description (#123)`

A breaking change adds a `BREAKING CHANGE:` footer:

```
feat(icm): my short commit description (#123)

BREAKING CHANGE: describe what breaks and the migration path for existing deployments
```

Whether a commit counts toward a chart's release is decided by the files it touches, not by its type: only commits that modify files under `charts/<chart>/` trigger a release for that chart. Among those, anything that is neither a `feat` nor a breaking change results in a _PATCH_ (this includes `docs`, `chore`, `build`, `test`, etc.). Commits that touch no chart directory are not released automatically, but should still be conventional and as informative as possible.

All of this will help to read and interpret our changelogs and release notes.
