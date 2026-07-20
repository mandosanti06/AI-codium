# AI-Codium Product and Architecture Design

**Status:** Approved design awaiting publication to the AI-Codium fork  
**Date:** 2026-07-20  
**Upstream:** `VSCodium/vscodium`  
**Initial platform:** macOS 12 or newer, arm64 and x64  
**License baseline:** Preserve the upstream MIT license and audit every bundled dependency and provider integration.

## 1. Product Definition

AI-Codium is a VSCodium-derived editor whose AI experience feels and works like the native Visual Studio Code Chat interface while remaining open to multiple model providers. It provides one chat surface, one project-aware conversation history, one tool and approval system, and one model selector across Claude, OpenAI and Codex, Gemini, GitHub Copilot where legally and technically supported, local models, and future providers.

The first usable release is a full agentic editor rather than a chat-only prototype. It includes native chat, manual and automatic model selection, project context, agentic file and terminal tools, MCP, inline assistance, secure approvals, provider fallback, prompt optimization, and configurable multi-agent collaboration.

Development is intended to be performed entirely by AI agents. Repository state, issues, branches, commits, pull requests, tests, decision records, and structured handoffs must therefore contain enough durable context for a new agent session to resume work without private conversation history.

## 2. Goals

1. Preserve the familiar VS Code Chat interaction model instead of creating a separate AI dashboard.
2. Allow all supported providers and models to appear in the same native model selector.
3. Support both authenticated local CLIs or subscriptions and direct API credentials as first-class backends.
4. Keep a provider-neutral conversation history that survives model and provider changes.
5. Route prompts automatically using task, capability, cost, latency, privacy, context, availability, and reliability signals.
6. Provide safe agentic access to files, search, diagnostics, terminals, Git, MCP tools, and editor actions.
7. Support Orchestrator, Parallel, and Manual Team collaboration modes, with Orchestrator as the default.
8. Maintain a practical upstream-sync path with VSCodium and Code OSS.
9. Make every development task resumable by a new AI session.

## 3. Non-Goals for v0.1

1. Windows and Linux release packaging. The architecture must remain portable, but v0.1 ships on macOS first.
2. Circumventing provider authentication, subscriptions, licensing, quotas, or terms of service.
3. Bundling proprietary extensions or assets without explicit permission.
4. Guaranteeing that a web subscription provides API access when the provider does not officially support that relationship.
5. Cloud synchronization of conversations. v0.1 history is local-first.
6. Training a proprietary foundation model.

## 4. Upstream and Repository Strategy

`VSCodium/vscodium` is a repository of build scripts, product configuration, assets, and patches that downloads and builds Microsoft Code OSS. It is not a full copy of the Code OSS source tree. AI-Codium will fork this repository, rename the fork to `AI-Codium`, keep `VSCodium/vscodium` as the upstream remote, and preserve the upstream build pipeline.

AI-Codium-specific Code OSS changes will be maintained as small, categorized patches applied during source preparation. Provider-neutral runtime code and bundled first-party extensions will live as ordinary source in the fork and be copied into the prepared Code OSS tree by explicit build steps. Patches must not include generated build artifacts.

Patch categories:

- `patches/aicodium/workbench`: native chat shell, selector, settings, approvals, and session integration.
- `patches/aicodium/platform`: service contracts, IPC, secure storage bridges, and lifecycle integration.
- `patches/aicodium/product`: product naming, defaults, menus, commands, and feature flags.
- `src/aicodium-runtime`: isolated provider, routing, tool, and agent runtime.
- `src/aicodium-extension`: bundled extension-host integration for editor APIs and supported extension interoperability.

Every patch must include an ownership header, a linked issue, an upstream Code OSS version, a purpose statement, and a focused verification command. Upstream sync is performed on a dedicated branch and must report cleanly applied, refreshed, and conflicting patches.

## 5. Architecture

AI-Codium uses a hybrid native-core plus isolated-runtime architecture.

### 5.1 Native workbench layer

The workbench owns all user-visible and policy-sensitive behavior:

- Sidebar, editor, quick, and inline chat surfaces
- Conversation list and project association
- Model and `Auto` selector
- Context attachments and visible context budget
- Ask, edit, plan, and agent workflows
- Tool-call cards, diffs, checkpoints, approvals, and undo
- Provider and model attribution
- Collaboration mode selection
- Settings, notifications, and error recovery actions

The workbench depends only on provider-neutral service interfaces. It must not import provider SDKs or parse provider-specific output.

### 5.2 AI runtime

The isolated runtime owns:

- Provider discovery and adapter lifecycle
- CLI subprocess and pseudoterminal management
- Direct API clients
- Capability registry
- Context compilation and prompt optimization
- Routing and fallback
- Tool planning and execution coordination
- Multi-agent orchestration
- Usage, latency, health, and evaluation signals

The runtime communicates with the workbench over a versioned, typed IPC protocol. Messages use stable IDs, support streaming and cancellation, and carry capability and permission metadata. Provider SDK failures must not crash the editor process.

### 5.3 Bundled first-party extension

The bundled extension provides access to extension-host APIs that should not be duplicated in the workbench, including language features, workspace symbols, diagnostics, extension-contributed tools, supported MCP registration, and lawful interoperability with user-installed extensions.

### 5.4 Core service boundaries

- `ProviderRegistry`: lists authenticated providers and live model capabilities.
- `ConversationService`: persists provider-neutral sessions and messages.
- `ContextService`: resolves attachments and compiles bounded request context.
- `RoutingService`: selects a model or validates a manual choice.
- `AgentService`: runs one agent turn and coordinates tool calls.
- `CollaborationService`: executes Orchestrator, Parallel, or Manual Team strategies.
- `PermissionService`: evaluates and records tool approvals.
- `CheckpointService`: snapshots reversible workspace state before mutations.
- `EvaluationService`: records local quality, latency, reliability, and routing fixtures without uploading source content.

## 6. Native Chat Experience

AI-Codium follows the current VS Code Chat mental model:

- Chat is available in the sidebar and editor area.
- A user may attach files, folders, symbols, selections, diagnostics, terminal output, Git changes, and other supported context.
- The input supports commands, mentions, modes, tools, and reusable instructions.
- Responses stream into the conversation and show the provider and model that produced them.
- Tool calls and file edits are rendered as native cards and diffs.
- Checkpoints permit inspection and rollback of agent changes.
- Conversation history remains available after switching providers.

The model selector contains:

- `Auto`
- Provider groups
- Model capability badges
- Authentication and availability state
- Context-window and modality indicators
- Cost class for API-backed models
- Local or remote execution indicator

Manual selection pins the chosen model until the user unpins it or the model becomes unavailable. Automatic fallback after a pinned model fails requires a visible notification and follows the configured fallback policy.

## 7. Provider System

Every backend implements a versioned `ModelProvider` contract with:

- Identity and display metadata
- Supported authentication methods
- Authentication state and account label
- Dynamic model discovery
- Capability metadata
- Streaming chat generation
- Structured tool calls when available
- Cancellation
- Usage and rate-limit reporting when available
- Health checks and normalized errors
- Optional native session import or continuation where officially supported

Initial provider families:

1. Claude Code authenticated through an officially supported local login, plus the Anthropic API.
2. Codex authenticated through an officially supported ChatGPT login, plus the OpenAI API.
3. Gemini CLI authenticated through an officially supported Google login, plus the Gemini API.
4. GitHub Copilot through a technically and legally supported editor integration. No proprietary extension is bundled without permission.
5. OpenAI-compatible local and remote endpoints, including user-configured Ollama or LM Studio endpoints.

CLI and API variants remain distinct backends because their capabilities, billing, session behavior, context control, and tool semantics may differ. The UI may group them under one provider family but must disclose the active backend.

Adapters must not scrape browser sessions, copy tokens from unrelated applications, bypass quotas, or claim subscription compatibility that the provider does not officially offer.

## 8. Conversation and Context Model

AI-Codium owns the canonical conversation record. The local store records sessions, branches, messages, model attribution, attachments, tool calls, approvals, checkpoints, routing decisions, and summaries. Secrets and raw credential material are never stored in the conversation database.

Conversations are associated with a workspace identity but are not committed into the workspace by default. Users can export a redacted conversation explicitly.

The context compiler constructs each provider request from:

1. System and repository instructions
2. Current user request
3. Selected or inferred workspace context
4. Relevant conversation turns or summaries
5. Tool definitions allowed for the current mode
6. Provider-specific formatting and token limits

The compiler sends only context needed for the request. It shows attached and inferred context in the UI and respects excluded paths, secret patterns, workspace trust, and privacy settings.

## 9. Routing and Prompt Optimization

`Auto` routing filters models by hard requirements, then scores eligible choices.

Hard requirements include authentication, availability, modality, minimum context, required tool support, local-only policy, provider allowlists, budget ceilings, and organizational restrictions.

Scoring signals include:

- Task class and language
- Estimated complexity
- Required reasoning or coding behavior
- Context size
- Expected quality for the task class
- Expected API cost
- Recent latency
- Recent error and rate-limit rate
- User preference
- Provider diversity within a delegated workflow

The UI records the selected model and a concise reason. Detailed routing diagnostics are available on demand. The router never invents exact cost data when a provider does not expose it.

Prompt optimization is off or conservative by default for manually selected models and enabled according to policy for `Auto`. Optimized prompts are inspectable, reversible, and recorded separately from the user's original text. Optimization must preserve quoted text, code, constraints, and requested output format.

Fallback is a policy with ordered constraints rather than a hard-coded provider list. A fallback cannot weaken local-only or privacy requirements. Switching providers is visible in the conversation.

## 10. Agent Tools, Permissions, and Recovery

Initial tools cover read-only workspace inspection, text search, file edits, file creation, terminal commands, diagnostics, tests, Git status and diffs, supported Git mutations, MCP tools, and editor actions.

The permission broker evaluates the exact operation, path, command, network destination, and data exposure. User decisions are:

- Allow once
- Allow for this session
- Allow according to a saved rule
- Deny

Destructive commands, writes outside the workspace, secret access, external messages, publishing, credential changes, and materially irreversible actions require explicit approval. Broad unresolved paths, globs, environment variables, or command substitutions cannot be used to justify destructive actions.

Before workspace mutations, the checkpoint service records reversible state. Conflicting edits are detected using base revisions. Failed tool calls return structured errors and recovery actions. Cancellation must stop provider streams, queued tool calls, and child agents where safely possible.

## 11. Multi-Agent Collaboration

AI-Codium supports three collaboration modes as global settings with per-chat overrides.

### 11.1 Orchestrator, default

One lead model owns the user-facing turn. It may delegate bounded tasks to worker models based on capabilities and routing policy. Workers receive the minimum necessary context and return structured results. The orchestrator synthesizes the final response and identifies contributors. Concurrent file-writing workers require non-overlapping scopes or a merge stage.

### 11.2 Parallel

Multiple selected models work independently. A configured judge or deterministic comparison step synthesizes results. Usage, latency, and provider count limits are explicit settings. Parallel mode does not permit uncoordinated writes to the same files.

### 11.3 Manual Team

The user defines named agents, providers, models, instructions, tool permissions, and task assignments. Saved team templates may be reused. AI-Codium validates unavailable models and conflicting scopes before execution.

Every delegated task has an ID, owner, scope, status, parent turn, input summary, output, tool history, and cancellation state. Delegation is visible and auditable.

## 12. Settings

Settings are available in the standard graphical Settings UI and JSON settings. Major groups are:

- Providers and authentication
- Models and aliases
- Default model or `Auto`
- Routing weights, limits, and fallbacks
- Prompt optimization
- Conversation retention and export
- Context exclusions and privacy
- Agent tools and approval defaults
- MCP servers
- Collaboration mode and team templates
- Local runtime endpoints
- Diagnostics and redacted logs

Security-sensitive settings are user-profile scoped and cannot be enabled by an untrusted workspace. Workspace settings may narrow permissions but cannot silently broaden them.

## 13. Security and Privacy

- API credentials use the macOS Keychain or provider-owned secure login store.
- Credentials and raw tokens are never written to settings, logs, prompts, conversations, issues, or crash reports.
- Logs are structured and redacted at creation time.
- Workspace trust gates tools, context discovery, MCP, and executable project instructions.
- Provider requests disclose which attachments and inferred context will leave the machine.
- Local-only mode rejects all remote providers and remote MCP servers.
- Tool output is treated as untrusted input and cannot silently change system policy.
- Provider adapters run with the least privilege practical for their transport.
- New adapters require threat modeling, dependency review, authentication review, and adversarial tests.

## 14. Failure Handling

Errors are normalized into authentication, configuration, unavailable model, rate limit, quota, context overflow, transport, provider, tool, permission, cancellation, and internal categories.

User-facing errors must state what failed, whether work was changed, and the safest next action. Retrying must be idempotent where practical. The runtime uses bounded retries with jitter only for transient failures. Authentication, permission, invalid request, and destructive-operation failures are never blindly retried.

Provider crashes are isolated and restartable. Conversation drafts and completed messages survive runtime restarts. Interrupted agent runs are marked incomplete and can be resumed from their last durable checkpoint after the user reviews pending effects.

## 15. AI-Only Development Protocol

The repository root contains `AGENTS.md` as the governing execution contract. It defines scope, architectural boundaries, security requirements, commands, issue workflow, branch naming, testing, commits, pull requests, blocking, recovery, and handoff behavior.

### 15.1 Issue readiness

An `ai-ready` issue contains:

- Objective and user value
- In-scope and out-of-scope behavior
- Dependencies and prerequisites
- Architecture references
- Expected files or discovery instructions
- Interfaces consumed and produced
- Ordered implementation checklist
- Acceptance criteria
- Exact verification commands and expected results
- Security and upstream-sync considerations
- Recovery guidance for likely failures

Issues that require product, licensing, credential, signing, or external-account decisions are labeled `needs-human-decision` and are not autonomous work items.

### 15.2 Start and resume

An agent must read, in order:

1. Root `AGENTS.md`
2. Assigned issue and linked dependencies
3. Relevant design and architecture decision records
4. Existing branch, commits, pull request, checks, and review comments
5. The latest structured handoff

The agent then restates the current objective in the PR work log before making changes. Conversation memory is optional and never authoritative.

### 15.3 Checkpoints

One issue maps to one branch and one pull request. Branches use `issue/<number>-<slug>`. Agents commit after each independently valid step using the issue number. Draft pull requests are opened early. The PR checklist and verification record are updated after each checkpoint.

Agents do not leave a deliberately broken branch merely to record progress. If a session may end during a failing test cycle, the handoff records the failing state and the last known-good commit. A work-in-progress commit is allowed only when clearly marked and when it preserves recoverable work without exposing secrets.

### 15.4 Structured handoff

Before ending or when blocked, the agent records:

- Issue, branch, PR, and current commit
- Completed checklist items
- Changed files and architectural decisions
- Commands and tests run with results
- Current failure or uncertainty
- Recovery attempts already made
- Remaining ordered steps
- Exact recommended next command
- Whether the worktree is clean

### 15.5 Blocking and recovery

Agents must diagnose a blocker, consult documented recovery paths, and attempt only safe in-scope alternatives. They preserve useful work and label the issue `blocked` when external authority, unavailable credentials, licensing decisions, or an upstream dependency prevents progress. Separate blockers become narrowly scoped follow-up issues linked to the original task.

Architecture changes require an Architecture Decision Record under `docs/decisions/`. Agents cannot silently change provider contracts, security policy, persisted schemas, or the upstream patch strategy.

### 15.6 Project status

`docs/agent/PROJECT_STATUS.md` is generated from issues, milestones, and pull requests. It records the current milestone, active work, dependency order, blockers, latest verified builds, and next `ai-ready` tasks. Generated status must not replace primary issue and PR evidence.

## 16. Testing Strategy

Testing is layered:

1. Contract tests validate every provider against deterministic fixtures.
2. Adapter tests simulate streaming, cancellation, rate limits, auth expiry, malformed output, and tool calls without paid network access.
3. Router evaluations use versioned task fixtures and assert eligibility, policy compliance, fallback, and explanation behavior.
4. Context tests verify relevance, token budgets, exclusions, secret redaction, and provider payload boundaries.
5. Permission tests cover path resolution, command parsing, workspace trust, destructive operations, and saved rules.
6. Multi-agent tests cover delegation graphs, cancellation, worker failure, synthesis, and write conflicts.
7. Workbench integration tests cover chat, model selection, provider switching, history, diffs, approvals, and recovery.
8. Patch tests apply AI-Codium patches to the pinned Code OSS revision and fail on drift.
9. macOS smoke tests cover arm64 and x64 build, launch, onboarding, keychain, provider connection, chat, tools, update, and uninstall behavior.
10. Security tests cover prompt injection boundaries, malicious tool output, secret leakage, dependency risks, and IPC validation.

Live provider tests are opt-in, quota-bounded, and never required for untrusted pull requests. Recorded fixtures contain no proprietary prompts, credentials, or user source code.

## 17. Milestones

### M0: Fork foundation and macOS build

Rename and brand the fork, establish upstream synchronization, reproduce macOS arm64 and x64 builds, add AI development governance, and document patch ownership.

### M1: Architecture and licensing spikes

Map Code OSS chat surfaces, prove a native provider in the model selector, validate the core/runtime protocol, and document technically and legally supported Copilot paths.

### M2: Provider runtime

Deliver the provider contract, capability registry, secure authentication, streaming, cancellation, normalized errors, and initial provider adapters.

### M3: Native unified chat

Deliver sidebar and editor chat, project-scoped local history, context attachments, manual selection, provider switching, and attribution.

### M4: Agent tools and safety

Deliver tools, MCP, permissions, diffs, checkpoints, undo, workspace trust, and redaction.

### M5: Automatic routing

Deliver task classification, eligibility rules, scoring, budgets, prompt optimization, explainable routing, fallback, and evaluation fixtures.

### M6: Multi-agent collaboration

Deliver Orchestrator, Parallel, and Manual Team modes with safe task and edit coordination.

### M7: Inline intelligence and v0.1 release

Deliver provider-neutral inline completion and inline chat, performance and security hardening, macOS packaging, migration documentation, and the release candidate.

## 18. v0.1 Acceptance Criteria

AI-Codium v0.1 is complete when:

1. A new user can install and launch a macOS arm64 or x64 build.
2. The user can authenticate at least one supported CLI backend and one direct API backend without storing plaintext credentials.
3. Supported models appear in one native selector with accurate availability and capability metadata.
4. The user can chat in the sidebar, attach project context, switch providers, and retain the same conversation.
5. `Auto` selects an eligible model, explains the selection, obeys privacy and budget constraints, and performs a visible safe fallback.
6. Agent mode can inspect and edit files, run an approved command, show a diff, checkpoint changes, and undo them.
7. MCP tools can be configured and invoked through the same permission broker.
8. Orchestrator mode can delegate a bounded task and return an attributed result in one conversation.
9. Parallel and Manual Team modes can be enabled in settings and overridden per chat.
10. Inline assistance can use any compatible selected provider.
11. Provider failures do not crash the editor or corrupt conversation state.
12. A fresh AI development session can resume an interrupted issue using only repository, issue, branch, PR, CI, and handoff state.
13. Required contract, integration, security, patch, and macOS smoke tests pass.
14. The upstream-sync procedure is documented and demonstrated against a newer compatible VSCodium revision.

## 19. Primary Risks and Mitigations

- **Upstream chat changes:** keep patches small, pin Code OSS revisions, test patch application, and isolate provider logic from workbench internals.
- **Copilot licensing or compatibility:** begin with a licensing and integration spike, avoid bundling proprietary code, and represent unsupported states honestly.
- **CLI instability:** use version detection, capability negotiation, bounded compatibility ranges, structured fixtures, and clear degraded modes.
- **Credential leakage:** centralize secure storage, redact at source, restrict logs, and test prompt and tool boundaries.
- **Uncontrolled agent edits:** require permission scopes, checkpoints, revision checks, and serialized writes for overlapping paths.
- **Router quality:** use transparent rules first, versioned evaluations, user overrides, and measured reliability rather than unsupported claims.
- **Scope size:** maintain milestone dependency order and require each issue to produce an independently testable result.
- **AI session discontinuity:** use small commits, early draft PRs, structured handoffs, issue-level scope, and CI as durable memory.

## 20. Backlog Organization

GitHub issues will be grouped under the eight milestones and labeled by type, subsystem, readiness, risk, and platform. Initial label families are:

- Type: `epic`, `feature`, `spike`, `test`, `docs`, `security`, `build`
- Subsystem: `workbench`, `runtime`, `provider`, `routing`, `context`, `tools`, `multi-agent`, `inline`, `upstream`
- State: `ai-ready`, `blocked`, `needs-human-decision`
- Risk: `security-sensitive`, `upstream-conflict-risk`, `licensing-risk`
- Platform: `macos`, `portable`

Epics describe milestone outcomes and link their child issues. Implementation issues are dependency-ordered and sized to produce one reviewable, testable pull request. Discovery spikes must end with a committed decision or interface fixture rather than an unstructured research summary.
