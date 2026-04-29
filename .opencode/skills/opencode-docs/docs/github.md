GitHub | OpenCode

On this page

-   [Overview](#_top)
-   [Features](#features)
-   [Installation](#installation)
-   [Configuration](#configuration)
-   [Supported Events](#supported-events)
-   [Custom prompts](#custom-prompts)
-   [Examples](#examples)

# GitHub

Use OpenCode in GitHub issues and pull-requests.

OpenCode integrates with your GitHub workflow. Mention `/opencode` or `/oc` in your comment, and OpenCode will execute tasks within your GitHub Actions runner.

---

## [Features](#features)

-   **Triage issues**: Ask OpenCode to look into an issue and explain it to you.
-   **Fix and implement**: Ask OpenCode to fix an issue or implement a feature. And it will work in a new branch and submits a PR with all the changes.
-   **Secure**: OpenCode runs inside your GitHub's runners.

---

## [Installation](#installation)

Run the following command in a project that is in a GitHub repo:

Terminal window

```
opencode github install
```

This will walk you through installing the GitHub app, creating the workflow, and setting up secrets.

---

### [Manual Setup](#manual-setup)

Or you can set it up manually.

1.  **Install the GitHub app**

    Head over to [**github.com/apps/opencode-agent**](https://github.com/apps/opencode-agent). Make sure it's installed on the target repository.

2.  **Add the workflow**

    Add the following workflow file to `.github/workflows/opencode.yml` in your repo:

    .github/workflows/opencode.yml

    ```
    name: opencode
    on:
      issue_comment:
        types: [created]
      pull_request_review_comment:
        types: [created]
    jobs:
      opencode:
        if: |
          contains(github.event.comment.body, '/oc') ||
          contains(github.event.comment.body, '/opencode')
        runs-on: ubuntu-latest
        permissions:
          id-token: write
        steps:
          - name: Checkout repository
            uses: actions/checkout@v6
            with:
              fetch-depth: 1
              persist-credentials: false
          - name: Run OpenCode
            uses: anomalyco/opencode/github@latest
            env:
              ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
            with:
              model: anthropic/claude-sonnet-4-20250514
    ```

3.  **Store the API keys in secrets**

    In your organization or project **settings**, expand **Secrets and variables** on the left and select **Actions**. And add the required API keys.

---

## [Configuration](#configuration)

-   `model`: The model to use with OpenCode. Takes the format of `provider/model`. This is **required**.
-   `agent`: The agent to use. Must be a primary agent.
-   `share`: Whether to share the OpenCode session. Defaults to **true** for public repositories.
-   `prompt`: Optional custom prompt to override the default behavior.
-   `token`: Optional GitHub access token for performing operations.

---

## [Supported Events](#supported-events)

| Event Type | Triggered By | Details |
|------------|-------------|---------|
| `issue_comment` | Comment on an issue or PR | Mention `/opencode` or `/oc` |
| `pull_request_review_comment` | Comment on specific code lines in a PR | Mention `/opencode` or `/oc` |
| `issues` | Issue opened or edited | Requires `prompt` input |
| `pull_request` | PR opened or updated | Useful for automated reviews |
| `schedule` | Cron-based schedule | Requires `prompt` input |
| `workflow_dispatch` | Manual trigger from GitHub UI | Requires `prompt` input |

---

## [Custom prompts](#custom-prompts)

Override the default prompt to customize OpenCode's behavior for your workflow.

```
- uses: anomalyco/opencode/github@latest
  with:
    model: anthropic/claude-sonnet-4-5
    prompt: |
      Review this pull request:
      - Check for code quality issues
      - Look for potential bugs
      - Suggest improvements
```

---

## [Examples](#examples)

-   **Explain an issue**

    ```
    /opencode explain this issue
    ```

-   **Fix an issue**

    ```
    /opencode fix this
    ```

-   **Review PRs and make changes**

    ```
    Delete the attachment from S3 when the note is removed /oc
    ```

-   **Review specific code lines**

    Leave a comment directly on code lines in the PR's "Files" tab.

Last updated: Apr 27, 2026
