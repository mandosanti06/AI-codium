# GitHub Project Configuration

Create one user-owned GitHub Project named `AI-Codium Development` and use GitHub issues and pull requests as its items.

## Views

1. `Roadmap`: table grouped by Milestone, sorted by Priority then issue number.
2. `Current`: board grouped by Status and filtered to the current milestone.
3. `Agent Queue`: table filtered to `Readiness = AI Ready` and `Status = Ready`, sorted by Priority.
4. `Blocked`: table filtered to `Status = Blocked` or `Readiness = Human Decision`.
5. `Pull Requests`: table filtered to pull requests and grouped by Review State.

## Fields

| Field | Type | Values |
| --- | --- | --- |
| Status | Single select | Backlog, Ready, In Progress, In Review, Blocked, Done |
| Milestone | Single select | M0, M1, M2, M3, M4, M5, M6, M7 |
| Priority | Single select | P0, P1, P2, P3 |
| Readiness | Single select | AI Ready, Human Decision, Research, Blocked |
| Subsystem | Single select | Governance, Build, Upstream, Workbench, Runtime, Provider, Context, Tools, Routing, Multi-agent, Inline, Release |
| Risk | Single select | Normal, Security, Licensing, Upstream Conflict |
| Estimate | Number | Whole-number ideal engineering days |
| Parent issue | Text | `#<epic number>` |

## Workflows

1. Auto-add every issue and pull request matching `repo:mandosanti06/AI-codium`.
2. Set new issues to `Backlog`.
3. Set newly opened draft pull requests to `In Progress`.
4. Set pull requests ready for review to `In Review`.
5. Set merged pull requests and closed issues to `Done`.
6. Do not auto-archive completed items because they are required for AI session reconstruction.

## Branch and pull-request policy

- One issue per branch using `issue/<number>-<slug>`.
- Open a draft pull request after the first tested checkpoint.
- Require pull requests, passing CI, and resolved review threads before `master` changes.
- Require linear history or squash merge for feature work.
- Allow upstream-sync PRs to preserve traceable merge commits when necessary.
- Delete merged issue branches automatically.

## One-time manual setup

The connected GitHub API used by the planning agent does not expose GitHub Projects or branch-protection mutations. A repository administrator must create the Project, fields, views, workflows, and protection rule described above. After the auto-add workflow is active, issue and PR lifecycle changes populate the board automatically.

