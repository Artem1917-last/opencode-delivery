Agent Skills | OpenCode

On this page

-   [Overview](#_top)
-   [Place files](#place-files)
-   [Understand discovery](#understand-discovery)
-   [Write frontmatter](#write-frontmatter)
-   [Validate names](#validate-names)
-   [Configure permissions](#configure-permissions)
-   [Troubleshoot loading](#troubleshoot-loading)

# Agent Skills

Define reusable behavior via SKILL.md definitions

Agent skills let OpenCode discover reusable instructions from your repo or home directory. Skills are loaded on-demand via the native `skill` tool.

---

## [Place files](#place-files)

Create one folder per skill name and put a `SKILL.md` inside it. OpenCode searches these locations:

-   Project config: `.opencode/skills/<name>/SKILL.md`
-   Global config: `~/.config/opencode/skills/<name>/SKILL.md`
-   Claude-compatible: `.claude/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`
-   Agent-compatible: `.agents/skills/<name>/SKILL.md` or `~/.agents/skills/<name>/SKILL.md`

---

## [Understand discovery](#understand-discovery)

For project-local paths, OpenCode walks up from your current working directory until it reaches the git worktree.

Global definitions are loaded from `~/.config/opencode/skills/*/SKILL.md`, `~/.claude/skills/*/SKILL.md`, and `~/.agents/skills/*/SKILL.md`.

---

## [Write frontmatter](#write-frontmatter)

Each `SKILL.md` must start with YAML frontmatter:

-   `name` (required)
-   `description` (required)
-   `license` (optional)
-   `compatibility` (optional)
-   `metadata` (optional)

---

## [Validate names](#validate-names)

`name` must:

-   Be 1-64 characters
-   Be lowercase alphanumeric with single hyphen separators
-   Not start or end with `-`
-   Not contain consecutive `--`
-   Match the directory name

Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

---

## [Follow length rules](#follow-length-rules)

`description` must be 1-1024 characters.

---

## [Use an example](#use-an-example)

Create `.opencode/skills/git-release/SKILL.md`:

```
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
---

## What I do
- Draft release notes from merged PRs
- Propose a version bump
- Provide a copy-pasteable `gh release create` command

## When to use me
Use this when you are preparing a tagged release.
```

---

## [Configure permissions](#configure-permissions)

Control which skills agents can access:

opencode.json

```
{  "permission": {    "skill": {      "*": "allow",      "pr-review": "allow",      "internal-*": "deny",      "experimental-*": "ask"    }  }}
```

| Permission | Behavior |
|------------|----------|
| `allow` | Skill loads immediately |
| `deny` | Skill hidden from agent |
| `ask` | User prompted for approval |

---

## [Override per agent](#override-per-agent)

**For custom agents** (in agent frontmatter):

```
---
permission:
  skill:
    "documents-*": "allow"
---
```

**For built-in agents** (in `opencode.json`):

```
{  "agent": {    "plan": {      "permission": {        "skill": {          "internal-*": "allow"        }      }    }  }}
```

---

## [Disable the skill tool](#disable-the-skill-tool)

**For custom agents**:

```
---
tools:
  skill: false
---
```

**For built-in agents**:

```
{  "agent": {    "plan": {      "tools": {        "skill": false      }    }  }}
```

---

## [Troubleshoot loading](#troubleshoot-loading)

If a skill does not show up:

1.  Verify `SKILL.md` is spelled in all caps
2.  Check that frontmatter includes `name` and `description`
3.  Ensure skill names are unique across all locations
4.  Check permissions—skills with `deny` are hidden

Last updated: Apr 27, 2026
