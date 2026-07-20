# Contributing

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

#### Table Of Contents

- [Code of Conduct](#code-of-conduct)
- [Reporting Bugs](#reporting-bugs)
- [Making Changes](#making-changes)

## Code of Conduct

This project and everyone participating in it is governed by the [VSCodium Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## AI-only development workflow

AI-Codium implementation work is performed entirely by AI agents. Human collaborators provide product direction, required approvals, credentials, licensing decisions, and review; they do not bypass the repository's AI execution contract with direct implementation changes.

Every implementation task must begin from an `ai-ready` GitHub issue and follow [AGENTS.md](AGENTS.md). The issue, branch, pull request, commits, verification record, and structured handoff are the durable record that lets a fresh AI session start, pause, block, or resume work without private conversation history.

- Use the AI-ready issue form to specify objective, scope, dependencies, acceptance criteria, verification, security impact, recovery, and handoff expectations.
- Use one `issue/<number>-<slug>` branch and one draft pull request for each issue. Commit each independently valid checkpoint with the issue number.
- Run the issue's verification commands and update the pull request record before transfer or review.
- When work cannot continue safely, follow the blocking and recovery procedure in `AGENTS.md`; record the exact blocker and required human decision rather than guessing.
- Do not place credentials, private source, or unredacted provider data in repository artifacts, issues, pull requests, or handoffs.

AI-Codium is derived from VSCodium. AI-Codium preserves the MIT License and its upstream relationship with `VSCodium/vscodium`. The VSCodium attribution and build references below remain useful for understanding the upstream project; AI-Codium-specific work follows the governance contract above.

## Reporting Bugs

### Before Submitting an Issue

Before creating bug reports, please check existing issues and [the Troubleshooting page](https://github.com/VSCodium/vscodium/blob/master/docs/troubleshooting.md) as you might find out that you don't need to create one.
When you are creating a bug report, please include as many details as possible. Fill out [the required template](https://github.com/VSCodium/vscodium/issues/new?&labels=bug&&template=bug_report.md), the information it asks for helps us resolve issues faster.

## Making Changes

AI agents must follow [AGENTS.md](AGENTS.md) before touching an issue, branch, file, or command. For AI-Codium-specific changes, use the issue workflow above and the approved architecture in `docs/superpowers/specs/2026-07-20-ai-codium-design.md`.

The following VSCodium documentation remains the source for upstream build and patch mechanics until an AI-Codium-specific procedure replaces it.

### Building VSCodium

To build VSCodium, please follow the command found in the section [`Build Scripts`](./docs/howto-build.md#build-scripts).

### Updating patches

If you want to update the existing patches, please follow the section [`Patch Update Process - Semi-Automated`](./docs/howto-build.md#patch-update-process-semiauto).

### Add a new patch

- first, you need to build VSCodium
- then use the command `./dev/patch.sh <your patch name>`, to initiate a new patch
- when the script pauses at `Press any key when the conflict have been resolved...`, open `vscode` directory in **VSCodium**
- run `npm run watch`
- run `./script/code.sh`
- make your changes
- press any key to continue the script `patch.sh`
