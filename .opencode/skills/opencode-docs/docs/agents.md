Agents | OpenCode

On this page

-   [Overview](#_top)
-   [Types](#types)
-   [Built-in](#built-in)
-   [Usage](#usage)
-   [Configure](#configure)
-   [Options](#options)
-   [Create agents](#create-agents)
-   [Examples](#examples)

# Agents

Configure and use specialized agents.

Agents are specialized AI assistants that can be configured for specific tasks and workflows.

Tip

Use the plan agent to analyze code and review suggestions without making any code changes.

---

## [Types](#types)

There are two types of agents in OpenCode; primary agents and subagents.

---

### [Primary agents](#primary-agents)

Primary agents are the main assistants you interact with directly. You can cycle through them using the **Tab** key.

---

### [Subagents](#subagents)

Subagents are specialized assistants that primary agents can invoke for specific tasks. You can also manually invoke them by **@ mentioning** them in your messages.

---

## [Built-in](#built-in)

OpenCode comes with two built-in primary agents and two built-in subagents.

---

### [Use build](#use-build)

*Mode*: `primary`

Build is the **default** primary agent with all tools enabled.

---

### [Use plan](#use-plan)

*Mode*: `primary`

A restricted agent designed for planning and analysis. By default, file edits and bash commands are set to `ask`.

---

### [Use general](#use-general)

*Mode*: `subagent`

A general-purpose agent for researching complex questions and executing multi-step tasks.

---

### [Use explore](#use-explore)

*Mode*: `subagent`

A fast, read-only agent for exploring codebases. Cannot modify files.

---

## [Usage](#usage)

1.  For primary agents, use the **Tab** key to cycle through them.
2.  Subagents can be invoked:
    -   **Automatically** by primary agents
    -   Manually by **@ mentioning** a subagent

---

## [Configure](#configure)

### [JSON](#json)

Configure agents in your `opencode.json` config file:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "agent": {    "code-reviewer": {      "description": "Reviews code for best practices",      "mode": "subagent",      "model": "anthropic/claude-sonnet-4-20250514",      "prompt": "You are a code reviewer.",      "permission": {        "edit": "deny"      }    }  }}
```

---

### [Markdown](#markdown)

You can also define agents using markdown files in:

-   Global: `~/.config/opencode/agents/`
-   Per-project: `.opencode/agents/`

---

## [Options](#options)

-   `description` - **Required**. Brief description of what the agent does.
-   `temperature` - Control randomness (0.0-1.0).
-   `steps` - Maximum number of agentic iterations.
-   `disable` - Set to `true` to disable the agent.
-   `prompt` - Custom system prompt file path.
-   `model` - Override the model for this agent.
-   `permission` - Configure permissions for the agent.
-   `mode` - `primary`, `subagent`, or `all` (default).
-   `hidden` - Hide subagent from autocomplete.
-   `color` - Customize visual appearance.
-   `top_p` - Control response diversity.

---

## [Create agents](#create-agents)

You can create new agents using:

Terminal window

```
opencode agent create
```

---

## [Examples](#examples)

### [Documentation agent](#documentation-agent)

```
---
description: Writes and maintains project documentation
mode: subagent
permission:
  bash: deny
---

You are a technical writer. Create clear, comprehensive documentation.
```

### [Security auditor](#security-auditor)

```
---
description: Performs security audits
mode: subagent
permission:
  edit: deny
---

You are a security expert. Focus on identifying potential security issues.
```

Last updated: Apr 27, 2026
