# AI-Codium Project Status

**Source of truth:** GitHub issues, pull requests, checks, and approved design documents  
**Current milestone:** M0, Fork Foundation and macOS Build  
**Latest approved design:** `docs/superpowers/specs/2026-07-20-ai-codium-design.md`

## Current state

- The VSCodium fork exists at `mandosanti06/AI-codium`.
- The product and architecture design is approved and committed.
- Issue #10 governance is implemented and under review in draft PR #46.
- Issue #10 remains open until draft PR #46 is merged.
- No product implementation issue should begin before issue #10 is closed.

## Execution order

1. Complete M0 governance and repository-management setup.
2. Prove clean macOS arm64 and x64 upstream builds.
3. Establish AI-Codium identity, patch ownership, and upstream synchronization.
4. Complete M1 architecture and licensing spikes.
5. Implement M2 through M7 in dependency order.

## Next AI-ready work

Issue #11 becomes the next autonomous task only after issue #10 closes. Confirm its current status on GitHub before starting.

## Session continuity

### Start or resume

Read `AGENTS.md`, the approved design, this status file, the assigned issue and dependencies, and the current branch, pull request, checks, reviews, and latest handoff. Only begin an open issue marked `ai-ready` whose dependencies are closed. The issue and pull request provide the current objective, acceptance criteria, verification record, and active checkpoint.

### Pause or transfer

Keep the current branch recoverable, commit any independently valid tested step, and add the structured handoff from `docs/agent/HANDOFF_TEMPLATE.md` to the active draft pull request. The handoff must name the current and last known-good commits, current failure or uncertainty, completed work, exact next command, and any required human decision.

### Blocked work

Capture the smallest reproduction, attempt only documented safe recoveries, preserve useful work, and mark the issue `blocked` when external authority, credentials, licensing, security approval, or an upstream dependency is required. Link a narrowly scoped follow-up issue when the blocker belongs elsewhere, then stop until the stated decision or dependency is resolved.

## Known human-managed setup

- Create the GitHub Project described in `docs/project-management.md`.
- Enable the Project auto-add workflow for issues and pull requests from `mandosanti06/AI-codium`.
- Configure repository branch protection after the baseline CI workflow is identified.

## Update rule

Update this file only when a milestone changes, a global blocker appears or clears, or the next dependency-free work set changes. Do not duplicate per-issue progress here.
