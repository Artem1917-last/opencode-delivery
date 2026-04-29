Go | OpenCode

On this page

-   [Overview](#_top)
-   [Background](#background)
-   [How it works](#how-it-works)
-   [Usage limits](#usage-limits)
-   [Endpoints](#endpoints)
-   [Privacy](#privacy)
-   [Goals](#goals)

# Go

Low cost subscription for open coding models.

OpenCode Go is a low cost subscription — **$5 for your first month**, then **$10/month** — that gives you reliable access to popular open coding models.

Note

OpenCode Go is currently in beta.

Go works like any other provider in OpenCode. You subscribe to OpenCode Go and get your API key. It's **completely optional** and you don't need to use it to use OpenCode.

It is designed primarily for international users, with models hosted in the US, EU, and Singapore for stable global access.

---

## [Background](#background)

Open models have gotten really good. They now reach performance close to proprietary models for coding tasks. And because many providers can serve them competitively, they are usually far cheaper.

However, getting reliable, low latency access to them can be difficult. Providers vary in quality and availability.

To fix this, we did a couple of things:

1.  We tested a select group of open models and talked to their teams about how to best run them.
2.  We then worked with a few providers to make sure these were being served correctly.
3.  Finally, we benchmarked the combination of the model/provider and came up with a list that we feel good recommending.

OpenCode Go gives you access to these models for **$5 for your first month**, then **$10/month**.

---

## [How it works](#how-it-works)

OpenCode Go works like any other provider in OpenCode.

1.  You sign in to **[OpenCode Zen](https://opencode.ai/auth)**, subscribe to Go, and copy your API key.
2.  You run the `/connect` command in the TUI, select `OpenCode Go`, and paste your API key.
3.  Run `/models` in the TUI to see the list of models available through Go.

The current list of models includes:

-   **GLM-5**
-   **GLM-5.1**
-   **Kimi K2.5**
-   **Kimi K2.6**
-   **MiMo-V2-Pro**
-   **MiMo-V2-Omni**
-   **MiMo-V2.5-Pro**
-   **MiMo-V2.5**
-   **MiniMax M2.5**
-   **MiniMax M2.7**
-   **Qwen3.5 Plus**
-   **Qwen3.6 Plus**
-   **DeepSeek V4 Pro**
-   **DeepSeek V4 Flash**

---

## [Usage limits](#usage-limits)

OpenCode Go includes the following limits:

-   **5 hour limit** — $12 of usage
-   **Weekly limit** — $30 of usage
-   **Monthly limit** — $60 of usage

Limits are defined in dollar value. This means your actual request count depends on the model you use.

### [Usage beyond limits](#usage-beyond-limits)

If you also have credits on your Zen balance, you can enable the **Use balance** option in the console. When enabled, Go will fall back to your Zen balance after you've reached your usage limits instead of blocking requests.

---

## [Endpoints](#endpoints)

You can also access Go models through the following API endpoints.

Model | Model ID | Endpoint
---|---|---
GLM-5.1 | glm-5.1 | `https://opencode.ai/zen/go/v1/chat/completions`
GLM-5 | glm-5 | `https://opencode.ai/zen/go/v1/chat/completions`
Kimi K2.5 | kimi-k2.5 | `https://opencode.ai/zen/go/v1/chat/completions`
Kimi K2.6 | kimi-k2.6 | `https://opencode.ai/zen/go/v1/chat/completions`
DeepSeek V4 Pro | deepseek-v4-pro | `https://opencode.ai/zen/go/v1/chat/completions`
DeepSeek V4 Flash | deepseek-v4-flash | `https://opencode.ai/zen/go/v1/chat/completions`
Qwen3.6 Plus | qwen3.6-plus | `https://opencode.ai/zen/go/v1/chat/completions`
Qwen3.5 Plus | qwen3.5-plus | `https://opencode.ai/zen/go/v1/chat/completions`

The [model id](/docs/config/#models) in your OpenCode config uses the format `opencode-go/<model-id>`.

---

## [Privacy](#privacy)

The plan is designed primarily for international users, with models hosted in the US, EU, and Singapore for stable global access. Our providers follow a zero-retention policy and do not use your data for model training.

---

## [Goals](#goals)

We created OpenCode Go to:

1.  Make AI coding **accessible** to more people with a low cost subscription.
2.  Provide **reliable** access to the best open coding models.
3.  Curate models that are **tested and benchmarked** for coding agent use.
4.  Have **no lock-in** by allowing you to use any other provider with OpenCode as well.

Last updated: Apr 27, 2026
