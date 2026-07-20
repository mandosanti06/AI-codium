#!/usr/bin/env bash

# Verifies the durable AI-session governance contract required by issue #10.
set -euo pipefail

require() {
  local pattern="$1"
  local file="$2"

  if ! grep -Fq "$pattern" "$file"; then
    printf 'Missing required governance text %q in %s\n' "$pattern" "$file" >&2
    exit 1
  fi
}

require 'Required reading' AGENTS.md
require 'Work selection' AGENTS.md
require 'Blocking and recovery' AGENTS.md
require 'Session handoff' AGENTS.md
require 'Completion' AGENTS.md
require 'One issue maps to one branch and one pull request.' AGENTS.md
require 'Use test-driven development for behavior changes.' AGENTS.md
require '## Worktree isolation' AGENTS.md
require 'Perform issue implementation in an isolated worktree at project-local `.worktrees/issue-<number>-<slug>`.' AGENTS.md
require 'Detect whether the host already provides an isolated worktree before creating one; do not create nested worktrees in a host-managed worktree.' AGENTS.md
require 'Verify the project-local `.worktrees/` path is ignored before creating the worktree.' AGENTS.md
require 'If the sandbox explicitly blocks creation, document the fallback in the issue work log (or PR work log once it exists), including the blocker, actual isolation boundary, and why it is safe to proceed.' AGENTS.md
require 'Before a draft PR exists, after branch creation and baseline verification, post a structured work log with the objective, scope, and baseline result to the GitHub issue.' AGENTS.md
require 'After the first valid checkpoint, open a draft PR, copy the work log into it, and keep the PR work log current.' AGENTS.md

require 'Dependencies and prerequisites' .github/ISSUE_TEMPLATE/implementation.yml
require 'Acceptance criteria' .github/ISSUE_TEMPLATE/implementation.yml
require 'Verification commands and expected results' .github/ISSUE_TEMPLATE/implementation.yml
require 'Recovery guidance' .github/ISSUE_TEMPLATE/implementation.yml
require 'Security, licensing, and upstream impact' .github/ISSUE_TEMPLATE/implementation.yml

require 'Exact next command' docs/agent/HANDOFF_TEMPLATE.md
require 'Last known-good commit' docs/agent/HANDOFF_TEMPLATE.md
require 'Human decision required' docs/agent/HANDOFF_TEMPLATE.md
require 'Recovery attempts' docs/agent/HANDOFF_TEMPLATE.md

require '## Verification' .github/pull_request_template.md
require '## Recovery and rollback' .github/pull_request_template.md
require '## AI handoff' .github/pull_request_template.md
require 'Last known-good commit:' .github/pull_request_template.md

require '# ADR 0000: Decision Title' docs/decisions/0000-template.md
require '## Context' docs/decisions/0000-template.md
require '## Decision' docs/decisions/0000-template.md
require '## Consequences' docs/decisions/0000-template.md
require '## Validation' docs/decisions/0000-template.md
require '## Reversal plan' docs/decisions/0000-template.md

require '# GitHub Project Configuration' docs/project-management.md
require 'AI-Codium Development' docs/project-management.md
require '## Branch and pull-request policy' docs/project-management.md
require 'Open a draft pull request after the first tested checkpoint.' docs/project-management.md
require 'Before a draft PR exists, record the structured work log on the GitHub issue after branch creation and baseline verification.' docs/project-management.md
require 'After the first valid checkpoint, open the draft PR, copy the work log into it, and keep it current there.' docs/project-management.md

require 'AI-only development workflow' CONTRIBUTING.md
require 'AGENTS.md' CONTRIBUTING.md
require 'VSCodium' CONTRIBUTING.md
require 'AI-Codium preserves the MIT License and its upstream relationship with `VSCodium/vscodium`.' CONTRIBUTING.md

require '## Session continuity' docs/agent/PROJECT_STATUS.md
require '### Start or resume' docs/agent/PROJECT_STATUS.md
require '### Pause or transfer' docs/agent/PROJECT_STATUS.md
require '### Blocked work' docs/agent/PROJECT_STATUS.md
require 'Only begin an open issue marked `ai-ready` whose dependencies are closed.' docs/agent/PROJECT_STATUS.md
require 'The issue and pull request provide the current objective, acceptance criteria, verification record, and active checkpoint.' docs/agent/PROJECT_STATUS.md
require 'Keep the current branch recoverable, commit any independently valid tested step, and add the structured handoff from `docs/agent/HANDOFF_TEMPLATE.md` to the active draft pull request.' docs/agent/PROJECT_STATUS.md
require 'The handoff must name the current and last known-good commits, current failure or uncertainty, completed work, exact next command, and any required human decision.' docs/agent/PROJECT_STATUS.md
require 'mark the issue `blocked` when external authority, credentials, licensing, security approval, or an upstream dependency is required.' docs/agent/PROJECT_STATUS.md
require 'then stop until the stated decision or dependency is resolved.' docs/agent/PROJECT_STATUS.md
require 'Issue #10 governance is implemented and under review in draft PR #46.' docs/agent/PROJECT_STATUS.md
require 'Issue #10 remains open until draft PR #46 is merged.' docs/agent/PROJECT_STATUS.md
require 'Issue #11 becomes the next autonomous task only after issue #10 closes.' docs/agent/PROJECT_STATUS.md

printf 'Governance contract: PASS\n'
