Providers | OpenCode

On this page

-   [Overview](#_top)
    -   [Credentials](#credentials)
    -   [Config](#config)
-   [OpenCode Zen](#opencode-zen)
-   [OpenCode Go](#opencode-go)
-   [Directory](#directory)
    -   [302.AI](#302ai)
    -   [Amazon Bedrock](#amazon-bedrock)
    -   [Anthropic](#anthropic)
    -   [Azure OpenAI](#azure-openai)
    -   [Azure Cognitive Services](#azure-cognitive-services)
    -   [Baseten](#baseten)
    -   [Cerebras](#cerebras)
    -   [Cloudflare AI Gateway](#cloudflare-ai-gateway)
    -   [Cloudflare Workers AI](#cloudflare-workers-ai)
    -   [Cortecs](#cortecs)
    -   [DeepSeek](#deepseek)
    -   [Deep Infra](#deep-infra)
    -   [Firmware](#firmware)
    -   [Fireworks AI](#fireworks-ai)
    -   [GitLab Duo](#gitlab-duo)
    -   [GitHub Copilot](#github-copilot)
    -   [Google Vertex AI](#google-vertex-ai)
    -   [Groq](#groq)
    -   [Hugging Face](#hugging-face)
    -   [Helicone](#helicone)
    -   [llama.cpp](#llamacpp)
    -   [IO.NET](#ionet)
    -   [LM Studio](#lm-studio)
    -   [Moonshot AI](#moonshot-ai)
    -   [MiniMax](#minimax)
    -   [NVIDIA](#nvidia)
    -   [Nebius Token Factory](#nebius-token-factory)
    -   [Ollama](#ollama)
    -   [Ollama Cloud](#ollama-cloud)
    -   [OpenAI](#openai)
    -   [OpenCode Zen](#opencode-zen-1)
    -   [OpenRouter](#openrouter)
    -   [LLM Gateway](#llm-gateway)
    -   [SAP AI Core](#sap-ai-core)
    -   [STACKIT](#stackit)
    -   [OVHcloud AI Endpoints](#ovhcloud-ai-endpoints)
    -   [Scaleway](#scaleway)
    -   [Together AI](#together-ai)
    -   [Venice AI](#venice-ai)
    -   [Vercel AI Gateway](#vercel-ai-gateway)
    -   [xAI](#xai)
    -   [Z.AI](#zai)
    -   [ZenMux](#zenmux)
-   [Custom provider](#custom-provider)
-   [Troubleshooting](#troubleshooting)

# Providers

Using any LLM provider in OpenCode.

OpenCode uses the [AI SDK](https://ai-sdk.dev/) and [Models.dev](https://models.dev) to support **75+ LLM providers** and it supports running local models.

To add a provider you need to:

1.  Add the API keys for the provider using the `/connect` command.
2.  Configure the provider in your OpenCode config.

---

### [Credentials](#credentials)

When you add a provider's API keys with the `/connect` command, they are stored in `~/.local/share/opencode/auth.json`.

---

### [Config](#config)

You can customize the providers through the `provider` section in your OpenCode config.

---

#### [Base URL](#base-url)

You can customize the base URL for any provider by setting the `baseURL` option. This is useful when using proxy services or custom endpoints.

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "provider": {    "anthropic": {      "options": {        "baseURL": "https://api.anthropic.com/v1"      }    }  }}
```

---

## [OpenCode Zen](#opencode-zen)

OpenCode Zen is a list of models provided by the OpenCode team that have been tested and verified to work well with OpenCode. [Learn more](/docs/zen).

Tip

If you are new, we recommend starting with OpenCode Zen.

1.  Run the `/connect` command in the TUI, select `OpenCode Zen`, and head to [opencode.ai/auth](https://opencode.ai/zen).
2.  Sign in, add your billing details, and copy your API key.
3.  Paste your API key.
4.  Run `/models` in the TUI to see the list of models we recommend.

It works like any other provider in OpenCode and is completely optional to use.

---

## [OpenCode Go](#opencode-go)

OpenCode Go is a low cost subscription plan that provides reliable access to popular open coding models provided by the OpenCode team that have been tested and verified to work well with OpenCode.

1.  Run the `/connect` command in the TUI, select `OpenCode Go`, and head to [opencode.ai/auth](https://opencode.ai/zen).
2.  Sign in, add your billing details, and copy your API key.
3.  Paste your API key.
4.  Run `/models` in the TUI to see the list of models we recommend.

It works like any other provider in OpenCode and is completely optional to use.

---

## [Directory](#directory)

Let's look at some of the providers in detail. If you'd like to add a provider to the list, feel free to open a PR.

Note

Don't see a provider here? Submit a PR.

---

### [302.AI](#302ai)

1.  Head over to the [302.AI console](https://302.ai/), create an account, and generate an API key.
2.  Run the `/connect` command and search for **302.AI**.
3.  Enter your 302.AI API key.
4.  Run the `/models` command to select a model.

---

### [Amazon Bedrock](#amazon-bedrock)

To use Amazon Bedrock with OpenCode:

1.  Head over to the **Model catalog** in the Amazon Bedrock console and request access to the models you want.
2.  **Configure authentication** using one of the following methods:

#### [Environment Variables (Quick Start)](#environment-variables-quick-start)

Set one of these environment variables while running opencode:

Terminal window

```
# Option 1: Using AWS access keys
AWS_ACCESS_KEY_ID=XXX AWS_SECRET_ACCESS_KEY=YYY opencode
# Option 2: Using named AWS profile
AWS_PROFILE=my-profile opencode
# Option 3: Using Bedrock bearer token
AWS_BEARER_TOKEN_BEDROCK=XXX opencode
```

#### [Configuration File (Recommended)](#configuration-file-recommended)

For project-specific or persistent configuration, use `opencode.json`:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "provider": {    "amazon-bedrock": {      "options": {        "region": "us-east-1",        "profile": "my-aws-profile"      }    }  }}
```

**Available options:**

-   `region` - AWS region (e.g., `us-east-1`, `eu-west-1`)
-   `profile` - AWS named profile from `~/.aws/credentials`
-   `endpoint` - Custom endpoint URL for VPC endpoints (alias for generic `baseURL` option)

---

### [Anthropic](#anthropic)

1.  Once you've signed up, run the `/connect` command and select Anthropic.
2.  Here you can select the **Claude Pro/Max** option and it'll open your browser and ask you to authenticate.
3.  Now all the Anthropic models should be available when you use the `/models` command.

---

### [Azure OpenAI](#azure-openai)

Note

If you encounter "I'm sorry, but I cannot assist with that request" errors, try changing the content filter from **DefaultV2** to **Default** in your Azure resource.

1.  Head over to the [Azure portal](https://portal.azure.com/) and create an **Azure OpenAI** resource.
2.  Go to [Azure AI Foundry](https://ai.azure.com/) and deploy a model.
3.  Run the `/connect` command and search for **Azure**.
4.  Enter your API key.
5.  Set your resource name as an environment variable.
6.  Run the `/models` command to select your deployed model.

---

### [GitHub Copilot](#github-copilot)

To use your GitHub Copilot subscription with opencode:

1.  Run the `/connect` command and search for GitHub Copilot.
2.  Navigate to [github.com/login/device](https://github.com/login/device) and enter the code.
3.  Now run the `/models` command to select the model you want.

---

### [Ollama](#ollama)

You can configure opencode to use local models through Ollama.

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "provider": {    "ollama": {      "npm": "@ai-sdk/openai-compatible",      "name": "Ollama (local)",      "options": {        "baseURL": "http://localhost:11434/v1"      },      "models": {        "llama2": {          "name": "Llama 2"        }      }    }  }}
```

---

### [OpenAI](#openai)

We recommend signing up for [ChatGPT Plus or Pro](https://chatgpt.com/pricing).

1.  Once you've signed up, run the `/connect` command and select OpenAI.
2.  Here you can select the **ChatGPT Plus/Pro** option and it'll open your browser and ask you to authenticate.
3.  Now all the OpenAI models should be available when you use the `/models` command.

---

## [Custom provider](#custom-provider)

You can define custom providers in your config file using the `provider` section.

---

## [Troubleshooting](#troubleshooting)

If you encounter `ProviderModelNotFoundError` you are most likely incorrectly referencing a model somewhere. Models should be referenced like so: `<providerId>/<modelId>`

Examples:

-   `openai/gpt-4.1`
-   `openrouter/google/gemini-2.5-flash`
-   `opencode/kimi-k2`

To figure out what models you have access to, run `opencode models`

Last updated: Apr 27, 2026
