Rules | OpenCode

On this page

-   [Overview](#_top)
-   [Initialize](#initialize)
-   [Example](#example)
-   [Types](#types)
-   [Precedence](#precedence)
-   [Custom Instructions](#custom-instructions)
-   [Referencing External Files](#referencing-external-files)

# Rules

Set custom instructions for opencode.

You can provide custom instructions to opencode by creating an `AGENTS.md` file. This is similar to Cursor's rules. It contains instructions that will be included in the LLM's context to customize its behavior for your specific project.

---

## [Initialize](#initialize)

To create a new `AGENTS.md` file, you can run the `/init` command in opencode.

Tip

You should commit your project's `AGENTS.md` file to Git.

`/init` scans the important files in your repo, may ask a couple of targeted questions, and then creates or updates `AGENTS.md` with concise project-specific guidance.

It focuses on:

-   build, lint, and test commands
-   architecture and repo structure
-   project-specific conventions
-   references to existing instruction sources

---

## [Example](#example)

You can also just create this file manually. Here's an example:

AGENTS.md

```
# SST v3 Monorepo Project
This is an SST v3 monorepo with TypeScript.

## Project Structure
- `packages/` - Contains all workspace packages
- `infra/` - Infrastructure definitions

## Code Standards
- Use TypeScript with strict mode enabled
- Shared code goes in `packages/core/`
```

---

## [Types](#types)

### [Project](#project)

Place an `AGENTS.md` in your project root for project-specific rules.

### [Global](#global)

You can also have global rules in a `~/.config/opencode/AGENTS.md` file. This gets applied across all opencode sessions.

### [Claude Code Compatibility](#claude-code-compatibility)

For users migrating from Claude Code, OpenCode supports Claude Code's file conventions as fallbacks:

-   **Project rules**: `CLAUDE.md` in your project directory
-   **Global rules**: `~/.claude/CLAUDE.md`
-   **Skills**: `~/.claude/skills/`

To disable Claude Code compatibility:

```
export OPENCODE_DISABLE_CLAUDE_CODE=1
```

---

## [Precedence](#precedence)

When opencode starts, it looks for rule files in this order:

1.  **Local files** by traversing up from the current directory (`AGENTS.md`, `CLAUDE.md`)
2.  **Global file** at `~/.config/opencode/AGENTS.md`
3.  **Claude Code file** at `~/.claude/CLAUDE.md` (unless disabled)

The first matching file wins in each category.

---

## [Custom Instructions](#custom-instructions)

You can specify custom instruction files in your `opencode.json`:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "instructions": ["CONTRIBUTING.md", "docs/guidelines.md", ".cursor/rules/*.md"]}
```

You can also use remote URLs:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "instructions": ["https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"]}
```

---

## [Referencing External Files](#referencing-external-files)

### [Using opencode.json](#using-opencodejson)

The recommended approach is to use the `instructions` field in `opencode.json`:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "instructions": ["docs/development-standards.md", "test/testing-guidelines.md"]}
```

### [Manual Instructions in AGENTS.md](#manual-instructions-in-agentsmd)

You can teach opencode to read external files by providing explicit instructions in your `AGENTS.md`.

Tip

For monorepos or projects with shared standards, using `opencode.json` with glob patterns is more maintainable.

Last updated: Apr 27, 2026
