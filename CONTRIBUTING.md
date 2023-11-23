# Contributing to the Intershop Helm Charts

Thank you for your interest in Intershops helm-chart project.

We look forward for any kind of contribution.

## Code of Conduct

We have adopted the [Contributor Covenants](https://www.contributor-covenant.org/) Code of Conduct and we expect project participants to adhere to it. Please read and follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

## Non-Code Contributions

You can contribute to the project without being a software developer. You can help by improving the documentation or analyzing the nature of an issue.

You have feedback? Please send it to devcommunity@intershop.com

## Contributor License Agreement

When you contribute please be aware that your contribution is covered by the same [license](./LICENSE) as the whole project. In order to contribute you must apply to the [Contributor License Agreement](./INTERSHOP_CLA.md). If you are an employee of a company we also need the approval from your company that you are authorized to do so. This is mainly to protect you as an employee.

Please note that you do not have to do this right now but only once you want to submit your first pull request.

Please print the contributor license agreement and send it to devcommunity@intershop.de.

If you have any questions feel free to also send them to this email address.

## Contribution process

1. Fork the repository
2. Use the `main` branch for your edits
3. Work on changes
4. Comment the changes
5. Check whether the changes comply with the the rules (design etc.)
6. Create a pull request
7. Add as much information as needed
8. Reference the solved issue
9. Wait for the review
10. PR is approved, denied (with explanation) or sent back for further information
11. We are trying to react as fast as possible to pull-request, issues, feedback and any other community interaction. However, we can’t guarantee a particular timeframe for every answer. We hope you understand and apologize for any inconveniences.

## Commit Message Guidelines

In general we comply with the rules and formats of [Conventional Commits](https://www.conventionalcommits.org).
These rules are essential to our automated release process and the later rollout of a helm chart. Commit messages will be used to determine the new semantic version and shall help updating existing projects.

Some rules to be emphasized for chart related commits:
* Every commit containing a `BREAKING_CHANGE` will be treated as a _MAJOR_ change, but please do also add a `!` to the semver-type of a commit (e.g.: fix(icm)!:). This will help reading changelogs and release notes.
* A commit message starting with `feat(icm):` (or e.g.: `feat(pwa):`) will get a _MINOR_ change.
* The rest will be _PATCH_ .

Chart unreleated commits (like e.g. docs, chore, build, test) will not be taken into account but still should be conventional and informative as possible.
