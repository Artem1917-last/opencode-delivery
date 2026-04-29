Zen | OpenCode

On this page

-   [Overview](#_top)
-   [Background](#background)
-   [How it works](#how-it-works)
-   [Endpoints](#endpoints)
-   [Pricing](#pricing)
-   [Privacy](#privacy)
-   [For Teams](#for-teams)
-   [Goals](#goals)

# Zen

Curated list of models provided by OpenCode.

OpenCode Zen is a list of tested and verified models provided by the OpenCode team.

Note

OpenCode Zen is currently in beta.

Zen works like any other provider in OpenCode. You login to OpenCode Zen and get your API key. It's **completely optional** and you don't need to use it to use OpenCode.

---

## [Background](#background)

There are a large number of models out there but only a few of these models work well as coding agents. Additionally, most providers are configured very differently; so you get very different performance and quality.

To fix this, we did a couple of things:

1.  We tested a select group of models and talked to their teams about how to best run them.
2.  We then worked with a few providers to make sure these were being served correctly.
3.  Finally, we benchmarked the combination of the model/provider and came up with a list that we feel good recommending.

OpenCode Zen is an AI gateway that gives you access to these models.

---

## [How it works](#how-it-works)

OpenCode Zen works like any other provider in OpenCode.

1.  You sign in to **[OpenCode Zen](https://opencode.ai/auth)**, add your billing details, and copy your API key.
2.  You run the `/connect` command in the TUI, select OpenCode Zen, and paste your API key.
3.  Run `/models` in the TUI to see the list of models we recommend.

You are charged per request and you can add credits to your account.

---

## [Endpoints](#endpoints)

You can also access our models through the following API endpoints.

Model | Model ID | Endpoint
---|---|---
GPT 5.5 | gpt-5.5 | `https://opencode.ai/zen/v1/responses`
GPT 5.5 Pro | gpt-5.5-pro | `https://opencode.ai/zen/v1/responses`
Claude Opus 4.7 | claude-opus-4-7 | `https://opencode.ai/zen/v1/messages`
Claude Opus 4.5 | claude-opus-4-5 | `https://opencode.ai/zen/v1/messages`
Claude Sonnet 4.5 | claude-sonnet-4-5 | `https://opencode.ai/zen/v1/messages`
Claude Haiku 4.5 | claude-haiku-4-5 | `https://opencode.ai/zen/v1/messages`
Qwen3.6 Plus | qwen3.6-plus | `https://opencode.ai/zen/v1/chat/completions`
Qwen3.5 Plus | qwen3.5-plus | `https://opencode.ai/zen/v1/chat/completions`
MiniMax M2.7 | minimax-m2.7 | `https://opencode.ai/zen/v1/chat/completions`
GLM 5.1 | glm-5.1 | `https://opencode.ai/zen/v1/chat/completions`
Kimi K2.5 | kimi-k2.5 | `https://opencode.ai/zen/v1/chat/completions`

The [model id](/docs/config/#models) in your OpenCode config uses the format `opencode/<model-id>`.

---

## [Pricing](#pricing)

We support a pay-as-you-go model. Below are the prices **per 1M tokens**.

Model | Input | Output | Cached Read | Cached Write
---|---|---|---|---
Big Pickle | Free | Free | Free | -
MiniMax M2.5 Free | Free | Free | Free | -
MiniMax M2.7 | $0.30 | $1.20 | $0.06 | $0.375
GLM 5.1 | $1.40 | $4.40 | $0.26 | -
Kimi K2.5 | $0.60 | $3.00 | $0.10 | -
Qwen3.6 Plus | $0.50 | $3.00 | $0.05 | $0.625
Qwen3.5 Plus | $0.20 | $1.20 | $0.02 | $0.25
Claude Opus 4.7 | $5.00 | $25.00 | $0.50 | $6.25
Claude Sonnet 4.5 | $3.00 | $15.00 | $0.30 | $3.75
Claude Haiku 4.5 | $1.00 | $5.00 | $0.10 | $1.25
GPT 5.5 | $5.00 | $30.00 | $0.50 | -

### [Auto-reload](#auto-reload)

If your balance goes below $5, Zen will automatically reload $20.

### [Monthly limits](#monthly-limits)

You can also set a monthly usage limit for the entire workspace and for each member of your team.

---

## [Privacy](#privacy)

All our models are hosted in the US. Our providers follow a zero-retention policy and do not use your data for model training, with some exceptions for free models during their preview period.

---

## [For Teams](#for-teams)

Zen also works great for teams. You can invite teammates, assign roles, curate the models your team uses, and more.

### [Roles](#roles)

-   **Admin**: Manage models, members, API keys, and billing
-   **Member**: Manage only their own API keys

### [Model access](#model-access)

Admins can enable or disable specific models for the workspace.

### [Bring your own key](#bring-your-own-key)

You can use your own OpenAI or Anthropic API keys while still accessing other models in Zen.

---

## [Goals](#goals)

We created OpenCode Zen to:

1.  **Benchmark** the best models/providers for coding agents.
2.  Have access to the **highest quality** options.
3.  Pass along any **price drops** by selling at cost.
4.  Have **no lock-in** by allowing you to use it with any other coding agent.

Last updated: Apr 27, 2026
