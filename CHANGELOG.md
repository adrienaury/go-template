# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes

- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## [4.0.0]

- `Changed` go-devcontainer version from v5 to v6 (golang 1.24).

## [3.1.0]

- `Added` go-devcontainer version from v5.0 to v5.1 (fix neon build steps order).
- `Added` miller version 6.12.0.

## [3.0.0]

- `Changed` go-devcontainer version from v4.0 to v5.0 (golang 1.23).

## [2.0.0]

- `Changed` go-devcontainer version from v3.1 to v4.0 (golang 1.22).

## [1.3.0]

- `Added` test-int-debug target.

## [1.2.0]

- `Added` go-devcontainer version from v2.0 to v3.1 (golang 1.21).
- `Added` miller version 6.8.0.

## [1.1.0]

- `Changed` go-devcontainer version from v1.0 to v2.0 (golang 1.20).

## [1.0.1]

- `Fixed` more portable neon info, tested in GitHub CodeSpaces.

## [1.0.0]

- `Changed` go-devcontainer version from v0.7 to v1.0 (golang 1.9).

## [0.8.0]

- `Changed` go-devcontainer version from v0.6 to v0.7 (golang 1.8).
- `Changed` miller version from v6.0.0 to v6.2.0

## [0.7.1]

- `Fixed` release github action break when dependabot is enabled.

## [0.7.0]

- `Changed` Upgrade go-devcontainer from v0.5 to v0.6.
- `Changed` Upgrade mlr from 5.10.2 to 6.0.0.

## [0.6.1]

- `Fixed` Disabling `golint` linter because it has been archived by the owner.

## [0.6.0]

- `Changed` Upgrade go-devcontainer from v0.4 to v0.5.

## [0.5.0]

- `Changed` Upgrade go-devcontainer from v0.3 to v0.4.

## [0.4.1]

- `Fixed` Regression on GitHub release action.

## [0.4.0]

- `Changed` Upgrade go-devcontainer from v0.2 to v0.3.
- `Changed` Execute GitHub actions on ci flavored container (smaller image).
- `Fixed` Refresh target when the repo has UPPERCASE letters.
- `Fixed` Autoset permissions when starting devcontainer on a git repo that was not cloned by vscode user.
- `Fixed` CONTRIB.md was renamed to CONTRIBUTING.md and initialized with basic instructions.
- `Fixed` Refresh target always recreate go.mod and go.sum.
- `Fixed` Promote target does not create tag.
- `Fixed` Docker-tag target complains about missing DOCKERHUB_PASS.

## [0.3.0]

- `Added` Colors in neon help target.
- `Added` License target to scan 3rd party licenses and generate notice file.
- `Added` Default GitHub action for CI checks, run on push or pull request events but only for the main branch.
- `Added` Default GitHub action for Release, run on new tags.
- `Fixed` Cleaner git ignore.
- `Changed` Improved default linters configuration, and cleaner gopls configuration.
- `Changed` Build target `docker-publish` renamed to `docker-push`.

## [0.2.0]

- `Fixed` Publish target works properly;
- `Changed` Publish target now depends from the `test-int` target.

## [0.1.0]

- `Added` First official version of the template.
