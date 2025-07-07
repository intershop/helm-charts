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
2. Use the appropriate `develop\?` branch as base for your feature branch. See [Release Process](https://github.com/intershop/helm-charts/wiki/Release-Process).
3. Work on changes.
4. Comment the changes.
5. Check whether the changes comply with the the rules (design etc.).
6. Commit changes according to our Commit Message Guidelines.
6. Create a pull request into the `develop\?` base branch.
7. Add as much information as needed.
8. Reference the solved issue.
9. Wait for the review.
10. The pull request is approved, denied (with explanation) or sent back for further information.
11. We are trying to react as fast as possible to pull requests, issues, feedback and any other community interaction. However, we cannot guarantee a particular timeframe for every answer. We hope you understand and apologize for any inconveniences.
12. If the pull request is approved, the changes shall be merged via squash commit to improve commit history readability.

## Commit Message Guidelines

In general, we comply with the rules and formats of [Conventional Commits](https://www.conventionalcommits.org).
These rules are essential to our automated release process and the later rollout of a helm chart. Commit messages will be used to determine the new semantic version and shall help updating existing projects.

Some rules to be emphasized for chart related commits:
* Every commit starting with `BREAKING CHANGE(icm):` will be treated as a _MAJOR_ change. Please also use the commit message body to give detailed information.
* A commit message starting with `feat(icm):` (or e.g.: `feat(pwa):`) will get a _MINOR_ change.
* The rest will be _PATCH_.

Please also enhance your commit message with an existing **GitHub issue number**, where detailed information could be found. Github will later on link the commit to the issue ticket automatically.

Here is a sample commit message: `feat(icm): my short commit description (#123)`

Chart unrelated commits (like e.g., docs, chore, build, test) will not be taken into account but should still be conventional and as informative as possible.

All of this will help to read and interpret our changelogs and release notes.
