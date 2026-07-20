# AI-Codium M0 Fork Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish an AI-resumable, upstream-compatible AI-Codium fork that produces verified macOS arm64 and x64 baseline builds and has safe branch, patch, and project-management conventions.

**Architecture:** Preserve the VSCodium build-script repository and its Code OSS preparation pipeline. AI-Codium changes are introduced through product configuration, categorized patches, bundled source copied during preparation, and repository governance that treats issues, draft PRs, commits, CI, ADRs, and handoffs as durable agent memory.

**Tech Stack:** Bash, jq, GitHub Actions, VSCodium build scripts, Code OSS patches, Markdown governance, shell-based contract tests.

## Global Constraints

- Initial build platform is macOS 12 or newer on arm64 and x64.
- Preserve the upstream MIT license and VSCodium attribution.
- Do not bundle proprietary extensions, credentials, tokens, or provider assets.
- Keep `VSCodium/vscodium` as the upstream source and document every AI-Codium patch.
- One issue maps to one branch and one draft pull request.
- All tasks follow `AGENTS.md` and produce structured verification evidence.

---

### Task 1: AI-only repository governance

**Files:**
- Create: `AGENTS.md`
- Create: `docs/agent/HANDOFF_TEMPLATE.md`
- Create: `docs/agent/PROJECT_STATUS.md`
- Create: `docs/decisions/0000-template.md`
- Create: `docs/project-management.md`
- Create: `.github/pull_request_template.md`
- Create: `.github/ISSUE_TEMPLATE/implementation.yml`

**Interfaces:**
- Consumes: approved product design at `docs/superpowers/specs/2026-07-20-ai-codium-design.md`
- Produces: authoritative start, resume, checkpoint, block, verification, and handoff procedures for every later issue

- [ ] **Step 1: Add governance documents and templates**

Use the exact rules in `AGENTS.md` and require issue objective, dependencies, readiness, acceptance criteria, verification, security, recovery, and handoff fields in the issue form and PR template.

- [ ] **Step 2: Verify required continuity sections**

Run:

```bash
rg -n "Required reading|Work selection|Blocking and recovery|Session handoff|Completion" AGENTS.md
rg -n "Exact next command|Last known-good commit|Human decision required" docs/agent/HANDOFF_TEMPLATE.md
rg -n "Dependencies|Acceptance criteria|Verification|Recovery" .github/ISSUE_TEMPLATE/implementation.yml
```

Expected: every expression matches at least once and each command exits `0`.

- [ ] **Step 3: Commit**

```bash
git add AGENTS.md docs/agent docs/decisions docs/project-management.md .github
git commit -m "docs(governance): add resumable AI workflow (#10)"
```

### Task 2: Reproducible upstream macOS baseline

**Files:**
- Modify: `.github/workflows/*macos*.yml` after identifying the stable upstream workflow
- Create: `docs/build/macos-baseline.md`
- Create: `tests/governance/test_macos_matrix.sh`

**Interfaces:**
- Consumes: upstream VSCodium build inputs and existing macOS workflow
- Produces: pinned, documented arm64 and x64 baseline build evidence used by all later patch work

- [ ] **Step 1: Write a failing workflow contract test**

Create `tests/governance/test_macos_matrix.sh` that resolves the stable macOS workflow and asserts it contains both `arm64` and `x64`, a pinned Node version source, artifact upload, and a build command documented in `docs/howto-build.md`.

- [ ] **Step 2: Run the test and record the baseline failure**

```bash
bash tests/governance/test_macos_matrix.sh
```

Expected: FAIL with one explicit missing requirement or PASS if upstream already meets every contract. Record either result in the PR.

- [ ] **Step 3: Make the workflow contract explicit**

Modify only the identified stable macOS workflow so both architectures build on pull requests that touch build scripts, patches, product configuration, runtime source, or bundled extension source. Keep release publishing disabled for pull requests.

- [ ] **Step 4: Document local and CI reproduction**

In `docs/build/macos-baseline.md`, record prerequisites, exact commands, expected artifacts, architecture, Code OSS revision, VSCodium revision, and failure recovery for patch drift, signing absence, and dependency download failures.

- [ ] **Step 5: Verify and commit**

```bash
bash tests/governance/test_macos_matrix.sh
git diff --check
git add .github/workflows docs/build tests/governance
git commit -m "ci(macos): establish reproducible baseline (#11)"
```

Expected: test PASS and `git diff --check` exits `0`.

### Task 3: AI-Codium product identity contract

**Files:**
- Modify: `prepare_vscode.sh`
- Modify: `product.json`
- Create: `docs/product/identity.md`
- Create: `tests/product/test_identity.sh`

**Interfaces:**
- Consumes: VSCodium product mutation functions in `prepare_vscode.sh`
- Produces: stable AI-Codium names, application identifiers, data directories, URL protocol, repository URLs, and update policy

- [ ] **Step 1: Write failing identity assertions**

The test must prepare or statically inspect stable product configuration and assert these exact values:

```text
nameShort=AI-Codium
nameLong=AI-Codium
applicationName=ai-codium
dataFolderName=.ai-codium
urlProtocol=ai-codium
serverApplicationName=ai-codium-server
serverDataFolderName=.ai-codium-server
darwinBundleIdentifier=io.github.mandosanti06.aicodium
reportIssueUrl=https://github.com/mandosanti06/AI-codium/issues/new/choose
licenseUrl=https://github.com/mandosanti06/AI-codium/blob/master/LICENSE
```

- [ ] **Step 2: Run the failing test**

```bash
bash tests/product/test_identity.sh
```

Expected: FAIL because the upstream product still identifies as VSCodium.

- [ ] **Step 3: Implement stable identity settings**

Use the existing `setpath` helpers in `prepare_vscode.sh`. Do not change Windows identifiers in this macOS-first issue. Set the update URL only after an AI-Codium release metadata design is approved; until then set `DISABLE_UPDATE=yes` in development workflows and document manual update behavior.

- [ ] **Step 4: Verify and commit**

```bash
bash tests/product/test_identity.sh
shellcheck prepare_vscode.sh tests/product/test_identity.sh
git diff --check
git add prepare_vscode.sh product.json docs/product tests/product
git commit -m "feat(product): establish AI-Codium identity (#12)"
```

Expected: all commands exit `0`.

### Task 4: Categorized AI-Codium patch and bundled-source pipeline

**Files:**
- Modify: `prepare_vscode.sh`
- Create: `patches/aicodium/README.md`
- Create: `src/aicodium-runtime/README.md`
- Create: `src/aicodium-extension/README.md`
- Create: `tests/patches/test_aicodium_pipeline.sh`

**Interfaces:**
- Consumes: upstream `apply_actions` and `apply_patch` functions from `utils.sh`
- Produces: deterministic application order and source-copy boundary for later workbench, platform, product, runtime, and extension changes

- [ ] **Step 1: Write a failing pipeline contract test**

Assert that preparation applies top-level upstream patches first, then lexically ordered AI-Codium action files and patches, then copies runtime and bundled-extension source to documented destinations. Assert missing optional category directories are harmless and any failed patch stops the build.

- [ ] **Step 2: Run the failing test**

```bash
bash tests/patches/test_aicodium_pipeline.sh
```

Expected: FAIL because categorized AI-Codium paths are not yet processed.

- [ ] **Step 3: Implement deterministic preparation**

Add explicit arrays for `product`, `platform`, and `workbench` categories. Do not use an unconstrained recursive glob. Copy `src/aicodium-runtime` and `src/aicodium-extension` only after their target paths are resolved under the prepared `vscode` directory.

- [ ] **Step 4: Document patch ownership**

`patches/aicodium/README.md` must define category order, patch header fields, regeneration commands, Code OSS version recording, test requirements, and conflict recovery.

- [ ] **Step 5: Verify and commit**

```bash
bash tests/patches/test_aicodium_pipeline.sh
shellcheck prepare_vscode.sh tests/patches/test_aicodium_pipeline.sh
git diff --check
git add prepare_vscode.sh patches/aicodium src/aicodium-runtime src/aicodium-extension tests/patches
git commit -m "build(patches): add AI-Codium source pipeline (#13)"
```

Expected: all commands exit `0`.

### Task 5: Upstream synchronization and drift reporting

**Files:**
- Create: `.github/workflows/upstream-sync-check.yml`
- Create: `dev/check-aicodium-patches.sh`
- Create: `docs/maintenance/upstream-sync.md`
- Create: `tests/patches/test_upstream_sync_contract.sh`

**Interfaces:**
- Consumes: VSCodium `master`, pinned Code OSS source revision, AI-Codium categorized patches
- Produces: non-destructive drift report and documented update procedure

- [ ] **Step 1: Write a failing synchronization contract test**

Assert that the workflow runs on a schedule and manual dispatch, never pushes or force-updates refs, invokes `dev/check-aicodium-patches.sh`, uploads a drift report, and exits nonzero when an AI-Codium patch cannot apply.

- [ ] **Step 2: Implement the read-only drift check**

The script must use a temporary prepared source directory, run existing source preparation, apply AI-Codium patches in production order, write a report listing upstream revision and conflicting patch, and clean temporary state without deleting the repository worktree.

- [ ] **Step 3: Document the human and AI recovery flow**

Document creation of `upstream/<vscodium-version>` branches, patch refresh, baseline build, regression checks, draft PR, and merge requirements. Force pushes to `master` are prohibited.

- [ ] **Step 4: Verify and commit**

```bash
bash tests/patches/test_upstream_sync_contract.sh
shellcheck dev/check-aicodium-patches.sh tests/patches/test_upstream_sync_contract.sh
git diff --check
git add .github/workflows/upstream-sync-check.yml dev/check-aicodium-patches.sh docs/maintenance tests/patches
git commit -m "ci(upstream): report VSCodium patch drift (#14)"
```

Expected: all commands exit `0`.

## M0 Completion Gate

M0 is complete only when governance is merged, both macOS architectures produce baseline artifacts, AI-Codium identity tests pass, categorized patches apply to the pinned Code OSS revision, upstream drift reporting works without mutating `master`, and the Project board plus branch protection are configured as described in `docs/project-management.md`.
