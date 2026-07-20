# AI-Codium Agent Contract

This file governs all AI-authored work in this repository. Read it before an issue, branch, file, or command is touched.

## Authority order

1. User instructions and repository security policy
2. This file
3. The assigned GitHub issue and its acceptance criteria
4. Approved design documents and Architecture Decision Records
5. Existing code and upstream VSCodium conventions

When two sources conflict, stop and record the conflict on the issue. Do not silently choose one.

## Required reading

Before starting or resuming work, read:

1. `AGENTS.md`
2. `docs/superpowers/specs/2026-07-20-ai-codium-design.md`
3. `docs/agent/PROJECT_STATUS.md`
4. The assigned issue, its dependency issues, and linked ADRs
5. The current branch, commits, draft PR, checks, reviews, and latest handoff

Conversation history is optional context and is never the source of truth.

## Work selection

- Work only on an open issue marked `ai-ready` in its body or status field.
- Do not start an issue whose dependencies are open.
- One issue maps to one branch and one pull request.
- Branch names use `issue/<number>-<short-slug>`.
- If no issue is assigned, select the earliest dependency-free item listed in `docs/agent/PROJECT_STATUS.md`.
- Issues marked `needs-human-decision`, `blocked`, `licensing-risk`, or `security-sensitive` require the approval stated in the issue before mutation begins.

## Before editing

1. Confirm the worktree and branch.
2. Pull or fetch current remote state without discarding local changes.
3. Reproduce the current baseline with the verification command from the issue.
4. Post or update the PR work log with the objective, scope, and baseline result.
5. Inspect overlapping active PRs. Do not modify the same subsystem concurrently without explicit coordination.

## Implementation rules

- Follow the approved hybrid architecture. Workbench code owns UI and policy. Provider-specific code stays in the isolated runtime or bundled extension.
- Keep AI-Codium patches small, categorized, documented, and testable against the pinned Code OSS revision.
- Do not bypass provider authentication, licensing, subscriptions, quotas, or terms.
- Never place credentials, tokens, private source, or unredacted provider payloads in commits, logs, fixtures, issues, or PRs.
- Use test-driven development for behavior changes. A failing test or verification fixture precedes the implementation unless the issue is an explicitly approved research spike.
- Do not broaden issue scope. Open a linked follow-up issue for adjacent work.
- Architecture, persisted schema, provider contract, security policy, and patch-strategy changes require an ADR under `docs/decisions/`.
- Preserve unrelated user and upstream changes.

## Checkpoints and commits

- Commit after each independently valid, tested step.
- Commit messages use `<type>(<scope>): <summary> (#<issue>)`.
- Push checkpoints to the issue branch and keep a draft PR open.
- Do not knowingly leave the branch broken. If a session ends during a failing test cycle, identify the last known-good commit in the handoff.
- A `WIP` commit is allowed only to preserve recoverable work. It must contain no secrets and the handoff must explain how to continue or revert it.

## Verification

- Run every command listed in the issue acceptance criteria.
- Record exact commands and results in the PR.
- CI is authoritative for completion.
- Live provider tests are opt-in, quota-bounded, and never required for untrusted PRs.
- An issue is complete only when acceptance criteria pass, documentation is current, the PR has a reproducible verification record, and no unresolved review thread remains.

## Blocking and recovery

When blocked:

1. Capture the exact failure and the smallest reproduction.
2. Check the issue recovery guidance, relevant ADRs, upstream documentation, and CI evidence.
3. Try only safe, in-scope alternatives.
4. Preserve useful work in a tested commit or clearly marked WIP commit.
5. Add a structured handoff to the draft PR.
6. Mark the issue `blocked` in its status section and open a narrowly scoped linked issue if the blocker belongs elsewhere.
7. Stop when resolution requires credentials, licensing interpretation, product authority, destructive action, or external coordination.

## Session handoff

Before a session ends, add a PR comment using `docs/agent/HANDOFF_TEMPLATE.md`. The handoff must include:

- Issue, branch, PR, and current commit
- Completed and remaining acceptance criteria
- Files changed and decisions made
- Commands and tests run with results
- Current failure, uncertainty, and attempted recoveries
- Exact next command
- Worktree cleanliness and last known-good commit

## Pull requests

- Open a draft PR after the first valid checkpoint.
- Link the issue with `Closes #<issue>` only when the PR fully satisfies it.
- Keep the PR body current. Do not depend on a final summary written from memory.
- Prefer squash merge after CI and review pass unless preserving distinct upstream-sync commits materially improves traceability.

## Completion

Before claiming completion:

1. Re-read the issue acceptance criteria.
2. Run the full required verification.
3. Inspect the final diff for secrets, generated artifacts, unrelated changes, and upstream-conflict risk.
4. Update documentation, ADRs, and `docs/agent/PROJECT_STATUS.md` when milestone state changes.
5. Record the verification evidence and remaining risks in the PR.

