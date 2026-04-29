Custom Tools | OpenCode

On this page

-   [Overview](#_top)
-   [Creating a tool](#creating-a-tool)
-   [Examples](#examples)

# Custom Tools

Create tools the LLM can call in opencode.

Custom tools are functions you create that the LLM can call during conversations.

---

## [Creating a tool](#creating-a-tool)

Tools are defined as **TypeScript** or **JavaScript** files.

### [Location](#location)

-   Locally: `.opencode/tools/` directory
-   Globally: `~/.config/opencode/tools/`

### [Structure](#structure)

Use the `tool()` helper:

.opencode/tools/database.ts

```
import { tool } from "@opencode-ai/plugin"

export default tool({  description: "Query the project database",  args: {    query: tool.schema.string().describe("SQL query to execute"),  },  async execute(args) {    return `Executed query: ${args.query}`  },})
```

The **filename** becomes the **tool name**.

#### [Multiple tools per file](#multiple-tools-per-file)

Export multiple tools from a single file:

.opencode/tools/math.ts

```
import { tool } from "@opencode-ai/plugin"

export const add = tool({  description: "Add two numbers",  args: {    a: tool.schema.number().describe("First number"),    b: tool.schema.number().describe("Second number"),  },  async execute(args) {    return args.a + args.b  },})

export const multiply = tool({  description: "Multiply two numbers",  args: {    a: tool.schema.number(),    b: tool.schema.number(),  },  async execute(args) {    return args.a * args.b  },})
```

This creates `math_add` and `math_multiply`.

#### [Name collisions with built-in tools](#name-collisions-with-built-in-tools)

If a custom tool uses the same name as a built-in tool, the custom tool takes precedence.

### [Arguments](#arguments)

Use `tool.schema` (Zod) to define argument types:

```
args: {  query: tool.schema.string().describe("SQL query to execute")}
```

### [Context](#context)

Tools receive context about the current session:

```
async execute(args, context) {  const { agent, sessionID, messageID, directory, worktree } = context  return `Agent: ${agent}, Session: ${sessionID}`}
```

---

## [Examples](#examples)

### [Write a tool in Python](#write-a-tool-in-python)

First, create the Python script:

.opencode/tools/add.py

```
import sys
a = int(sys.argv[1])b = int(sys.argv[2])print(a + b)
```

Then create the tool definition:

.opencode/tools/python-add.ts

```
import { tool } from "@opencode-ai/plugin"import path from "path"

export default tool({  description: "Add two numbers using Python",  args: {    a: tool.schema.number().describe("First number"),    b: tool.schema.number().describe("Second number"),  },  async execute(args, context) {    const script = path.join(context.worktree, ".opencode/tools/add.py")    const result = await Bun.$`python3 ${script} ${args.a} ${args.b}`.text()    return result.trim()  },})
```

Last updated: Apr 27, 2026
