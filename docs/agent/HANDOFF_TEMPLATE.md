# AI Session Handoff

Copy this template into the active draft pull request before pausing, blocking, or transferring work.

## Identity

- Issue: `#<number>`
- Branch: `issue/<number>-<slug>`
- Pull request: `#<number>`
- Current commit: `<full SHA>`
- Last known-good commit: `<full SHA>`

## Completed

- List completed issue checklist items and acceptance criteria.

## Changed

- List files changed and the reason for each change.
- List ADRs added or updated.

## Verification

| Command | Result | Evidence |
| --- | --- | --- |
| `<exact command>` | PASS or FAIL | `<concise output or CI link>` |

## Current state

- Describe the active failure, uncertainty, or incomplete step.
- State whether the worktree is clean.
- State whether the branch is safe for another agent to continue.

## Recovery attempts

1. Record each attempted recovery and its result.

## Remaining steps

1. Put the next required action first.
2. Keep the order dependency-safe.

## Exact next command

```bash
<one safe command that re-establishes or advances the task>
```

## Human decision required

- Write `None` or identify the exact decision and why the agent cannot make it.

