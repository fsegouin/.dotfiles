---
triggers:
  - create a ticket
  - create a jira ticket
  - file a bug
  - file a ticket
  - report a bug
  - report an issue
  - open a jira issue
  - create an issue
  - log a bug
  - make a ticket
  - new jira ticket
  - new ticket
  - jira ticket
  - create task in jira
  - create story in jira
  - audit finding ticket
---

# Ticket Creator Skill

You know how to create well-structured Jira tickets using templates. When the user wants to create a Jira ticket, follow this workflow.

## Workflow

### 1. Gather Context

- Check the current working directory, project config files (`CLAUDE.md`, `package.json`, etc.) to infer the project.
- If in a git repo, check `git status`, `git diff --stat`, and `git log --oneline -5` for recent work context.
- Use any context the user has already provided in conversation.

### 2. Determine Ticket Details

Ask the user to confirm or provide:

- **Project key** — Infer from context, validate with `jira_get_all_projects`. Ask if ambiguous.
- **Issue type** — Bug, Task, Story, or Epic. Default to Task.
- **Priority** — High, Medium, Low. Default to Medium.
- **Summary** — Draft from context or ask for one.
- **Description** — Build from the template matching the issue type (see below).

### 3. Apply the Right Template

Pick the template based on issue type:

**Bug:**
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
- OS:
- Version/Branch:
- Relevant config:

## Evidence
[Logs, screenshots, error messages]
```

**Task:**
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

**Story:**
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

**Audit Finding:**
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

Populate template fields with any context gathered from the workspace, git history, or conversation. Ask the user to fill in remaining gaps. Let them review and edit before creating.

### 4. Create the Ticket

Call `jira_create_issue` with all fields. Display the created ticket key and URL.

### 5. Post-Creation Actions

Offer the user these optional follow-up actions:

- **Link to related tickets** — Search with `jira_search`, then `jira_create_issue_link`
- **Assign to team member** — Use `jira_update_issue`
- **Add to sprint** — Use `jira_get_agile_boards` + `jira_get_sprints_from_board`
- **Link to epic** — Use `jira_link_to_epic`

## Tools Used

- `mcp__mcp-atlassian__jira_get_all_projects`
- `mcp__mcp-atlassian__jira_create_issue`
- `mcp__mcp-atlassian__jira_search`
- `mcp__mcp-atlassian__jira_update_issue`
- `mcp__mcp-atlassian__jira_create_issue_link`
- `mcp__mcp-atlassian__jira_link_to_epic`
- `mcp__mcp-atlassian__jira_get_agile_boards`
- `mcp__mcp-atlassian__jira_get_sprints_from_board`
- `mcp__mcp-atlassian__jira_get_transitions`
