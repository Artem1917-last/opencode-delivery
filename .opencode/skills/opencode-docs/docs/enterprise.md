Enterprise | OpenCode

On this page

-   [Overview](#_top)
-   [Trial](#trial)
    -   [Data handling](#data-handling)
    -   [Code ownership](#code-ownership)
-   [Pricing](#pricing)
-   [Deployment](#deployment)
    -   [Central Config](#central-config)
    -   [SSO integration](#sso-integration)
    -   [Internal AI gateway](#internal-ai-gateway)
    -   [Self-hosting](#self-hosting)
-   [FAQ](#faq)

# Enterprise

Using OpenCode securely in your organization.

OpenCode Enterprise is for organizations that want to ensure that their code and data never leaves their infrastructure. It can do this by using a centralized config that integrates with your SSO and internal AI gateway.

Note

OpenCode does not store any of your code or context data.

To get started with OpenCode Enterprise:

1.  Do a trial internally with your team.
2.  **[Contact us](mailto:contact@anoma.ly)** to discuss pricing and implementation options.

---

## [Trial](#trial)

OpenCode is open source and does not store any of your code or context data, so your developers can simply [get started](/docs/) and carry out a trial.

---

### [Data handling](#data-handling)

**OpenCode does not store your code or context data.** All processing happens locally or through direct API calls to your AI provider.

This means that as long as you are using a provider you trust, or an internal AI gateway, you can use OpenCode securely.

The only caveat here is the optional `/share` feature.

---

#### [Sharing conversations](#sharing-conversations)

If a user enables the `/share` feature, the conversation and the data associated with it are sent to the service we use to host these share pages at opencode.ai.

We recommend you disable this for your trial.

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "share": "disabled"}
```

[Learn more about sharing](/docs/share).

---

### [Code ownership](#code-ownership)

**You own all code produced by OpenCode.** There are no licensing restrictions or ownership claims.

---

## [Pricing](#pricing)

We use a per-seat model for OpenCode Enterprise. If you have your own LLM gateway, we do not charge for tokens used. For further details about pricing and implementation options, **[contact us](mailto:contact@anoma.ly)**.

---

## [Deployment](#deployment)

Once you have completed your trial and you are ready to use OpenCode at your organization, you can **[contact us](mailto:contact@anoma.ly)** to discuss pricing and implementation options.

---

### [Central Config](#central-config)

We can set up OpenCode to use a single central config for your entire organization.

This centralized config can integrate with your SSO provider and ensures all users access only your internal AI gateway.

---

### [SSO integration](#sso-integration)

Through the central config, OpenCode can integrate with your organization's SSO provider for authentication.

This allows OpenCode to obtain credentials for your internal AI gateway through your existing identity management system.

---

### [Internal AI gateway](#internal-ai-gateway)

With the central config, OpenCode can also be configured to use only your internal AI gateway.

You can also disable all other AI providers, ensuring all requests go through your organization's approved infrastructure.

---

### [Self-hosting](#self-hosting)

While we recommend disabling the share pages to ensure your data never leaves your organization, we can also help you self-host them on your infrastructure.

This is currently on our roadmap. If you're interested, **[let us know](mailto:contact@anoma.ly)**.

---

## [FAQ](#faq)

What is OpenCode Enterprise?

OpenCode Enterprise is for organizations that want to ensure that their code and data never leaves their infrastructure.

How do I get started with OpenCode Enterprise?

Simply start with an internal trial with your team. OpenCode by default does not store your code or context data, making it easy to get started.

Then **[contact us](mailto:contact@anoma.ly)** to discuss pricing and implementation options.

Is my data secure with OpenCode Enterprise?

Yes. OpenCode does not store your code or context data. All processing happens locally or through direct API calls to your AI provider.

Last updated: Apr 27, 2026
