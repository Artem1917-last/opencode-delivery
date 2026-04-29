GitLab | OpenCode

On this page

-   [Overview](#_top)
-   [GitLab CI](#gitlab-ci)
-   [GitLab Duo](#gitlab-duo)

# GitLab

Use OpenCode in GitLab issues and merge requests.

OpenCode integrates with your GitLab workflow through your GitLab CI/CD pipeline or with GitLab Duo.

In both cases, OpenCode will run on your GitLab runners.

---

## [GitLab CI](#gitlab-ci)

OpenCode works in a regular GitLab pipeline. You can build it into a pipeline as a [CI component](https://docs.gitlab.com/ee/ci/components/)

Here we are using a community-created CI/CD component for OpenCode — [nagyv/gitlab-opencode](https://gitlab.com/nagyv/gitlab-opencode).

---

### [Features](#features)

-   **Use custom configuration per job**: Configure OpenCode with a custom configuration directory.
-   **Minimal setup**: The CI component sets up OpenCode in the background.
-   **Flexible**: The CI component supports several inputs for customizing its behavior

---

### [Setup](#setup)

1.  Store your OpenCode authentication JSON as a File type CI environment variables under **Settings** > **CI/CD** > **Variables**.

2.  Add the following to your `.gitlab-ci.yml` file.

    .gitlab-ci.yml

    ```
    include:
      - component: $CI_SERVER_FQDN/nagyv/gitlab-opencode/opencode@2
        inputs:
          config_dir: ${CI_PROJECT_DIR}/opencode-config
          auth_json: $OPENCODE_AUTH_JSON
          command: optional-custom-command
          message: "Your prompt here"
    ```

---

## [GitLab Duo](#gitlab-duo)

OpenCode integrates with your GitLab workflow. Mention `@opencode` in a comment, and OpenCode will execute tasks within your GitLab CI pipeline.

---

### [Features](#features-1)

-   **Triage issues**: Ask OpenCode to look into an issue and explain it to you.
-   **Fix and implement**: Ask OpenCode to fix an issue or implement a feature. It will create a new branch and raise a merge request with the changes.
-   **Secure**: OpenCode runs on your GitLab runners.

---

### [Setup](#setup-1)

OpenCode runs in your GitLab CI/CD pipeline, here's what you'll need to set it up:

1.  Configure your GitLab environment
2.  Set up CI/CD
3.  Get an AI model provider API key
4.  Create a service account
5.  Configure CI/CD variables
6.  Create a flow config file

---

### [Examples](#examples)

-   **Explain an issue**

    ```
    @opencode explain this issue
    ```

-   **Fix an issue**

    ```
    @opencode fix this
    ```

-   **Review merge requests**

    ```
    @opencode review this merge request
    ```

Last updated: Apr 27, 2026
