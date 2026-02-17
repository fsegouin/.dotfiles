---
allowed-tools:
  - mcp__mcp-atlassian__jira_get_all_projects
  - mcp__mcp-atlassian__jira_create_issue
  - mcp__mcp-atlassian__jira_search
  - mcp__mcp-atlassian__jira_update_issue
  - mcp__mcp-atlassian__jira_create_issue_link
  - mcp__mcp-atlassian__jira_link_to_epic
  - mcp__mcp-atlassian__jira_get_agile_boards
  - mcp__mcp-atlassian__jira_get_sprints_from_board
  - mcp__mcp-atlassian__jira_get_transitions
  - mcp__mcp-atlassian__jira_get_issue
  - mcp__mcp-atlassian__jira_search_fields
argument-hint: description of the issue to create
---

# Create Jira Ticket

Create a Jira ticket interactively, gathering context from the current workspace and guiding through template-based issue creation.

## Phase 1: Gather Context

1. **Workspace context**: Read the current directory name, and look for `CLAUDE.md`, `package.json`, or other project config files to infer the project name and context.
2. **Arguments**: If `$ARGUMENTS` is provided, use it as the initial issue description or summary.
3. **Git context** (if in a git repo): Check `git status`, `git diff --stat`, and `git log --oneline -5` to understand recent work context. This can help populate ticket descriptions with relevant file paths and changes.

## Phase 2: Determine Ticket Details

Use `AskUserQuestion` to confirm or collect the following. Pre-fill with inferred values where possible.

1. **Project key** — Infer from directory name, `CLAUDE.md`, or other config. Validate by calling `jira_get_all_projects`. If ambiguous, ask the user to pick from available projects.
2. **Issue type** — Ask the user: Bug, Task, Story, or Epic. Default to Task if unclear.
3. **Priority** — Ask the user: High, Medium, Low. Default to Medium.
4. **Summary** — Draft from `$ARGUMENTS` or context, or ask the user to provide one.
5. **Description** — Build from the appropriate template (see Phase 3).

Ask these in a single `AskUserQuestion` call where feasible to minimize back-and-forth, except for description which requires the issue type to be known first.

## Phase 3: Build Description from Template

Based on the selected issue type, use the matching template below. Populate fields with gathered context (file paths, git info, user input). Ask the user to fill in any gaps.

### Bug Template

```
## Description
[What is the bug?]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS: [e.g., Linux, macOS, Windows]
- Version/Branch: [e.g., main, v2.1.0]
- Relevant config: [if applicable]

## Evidence
[Logs, screenshots, error messages — paste or reference file paths]
```

### Task Template

```
## Description
[What needs to be done and why]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Technical Notes
[Implementation hints, constraints, dependencies]

## Files Affected
[List of files or modules likely to be changed]
```

### Story Template

```
## Description
As a [type of user], I want [goal] so that [reason].

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Technical Notes
[Implementation hints, constraints, dependencies]
```

### Audit Finding Template

```
## Audit Source
- **Audit**: [Name of audit or review]
- **Severity**: [Critical / High / Medium / Low / Informational]
- **Date**: [Date of finding]

## Issue
[Description of the finding]

## Impact
[What is the risk or consequence]

## Recommendation
[Suggested fix or mitigation]

## Location
[File paths, modules, or systems affected]
```

Let the user review and edit the description before proceeding.

## Phase 4: Create the Ticket

1. Call `jira_create_issue` with all gathered fields (project key, summary, issue type, description, priority via `additional_fields`).
2. On success, display the created ticket key (e.g., `PROJ-123`) and the Jira URL.

## Phase 5: Post-Creation Actions

After the ticket is created, ask the user if they want any of the following:

1. **Link to related tickets** — Search for related issues using `jira_search` with keywords from the summary/description. Present matches and let the user pick which to link. Use `jira_create_issue_link` to create the link.
2. **Assign to a team member** — Ask for the assignee name/email, then call `jira_update_issue` to set the assignee.
3. **Add to a sprint** — Find the board with `jira_get_agile_boards`, list sprints with `jira_get_sprints_from_board`, and let the user pick. Update the issue accordingly.
4. **Link to an epic** — Ask for the epic key or search for epics, then use `jira_link_to_epic`.
5. **Done** — No further actions needed.

Present these as options in a single `AskUserQuestion` call with `multiSelect: true`.
