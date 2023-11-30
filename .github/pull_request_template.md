<!--
## PR Checklist
Please check if your PR fulfills the following requirements:

- [ ] The commit message follows our guidelines: https://github.com/intershop/helm-charts/blob/develop/CONTRIBUTING.md
- [ ] Docs have been added / updated (for bug fixes / features)
- [ ] Be sure to include PR label `major`, `minor` or `patch` when merging into `main`
-->

## PR Type

<!--
What kind of change does this PR introduce?
Please check the one that applies to this PR using "x".
-->

- [ ] Bugfix
- [ ] Feature
- [ ] Code style update (formatting, local variables)
- [ ] Refactoring (no functional changes, no API changes)
- [ ] Build-related changes
- [ ] CI-related changes
- [ ] Documentation content changes
- [ ] Application / infrastructure changes

## Release ##

Be sure that pull requests are build according to the defined release process [here](https://github.com/intershop/helm-charts/wiki/Release-Process). As a main part to mention here is that the semantic version type will be read from the commit messages (`BREAKING CHANGE(icm):` marks a *major* change, `feat(icm):` marks *minor* changes and the rest will be *patch*. So the developer must already know and is responsible.

## What Is the Current Behavior?

<!-- Please describe the current behavior that you are modifying, or link to a relevant issue. -->

Issue Number: Closes #

## What Is the New Behavior?

## Does this PR Introduce a Breaking Change?

<!-- If this PR contains a breaking change, please describe the impact and migration path for existing applications below. -->

- [ ] Yes
- [ ] No

## Other Information
