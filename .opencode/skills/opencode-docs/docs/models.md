Models | OpenCode

On this page

-   [Overview](#_top)
-   [Providers](#providers)
-   [Select a model](#select-a-model)
-   [Recommended models](#recommended-models)
-   [Set a default](#set-a-default)
-   [Configure models](#configure-models)
-   [Variants](#variants)
-   [Loading models](#loading-models)

# Models

Configuring an LLM provider and model.

OpenCode uses the [AI SDK](https://ai-sdk.dev/) and [Models.dev](https://models.dev) to support **75+ LLM providers** and it supports running local models.

---

## [Providers](#providers)

Most popular providers are preloaded by default. Learn more about [providers](/docs/providers).

---

## [Select a model](#select-a-model)

Once you've configured your provider you can select the model:

```
/models
```

---

## [Recommended models](#recommended-models)

Here are several models that work well with OpenCode:

-   GPT 5.2
-   GPT 5.1 Codex
-   Claude Opus 4.5
-   Claude Sonnet 4.5
-   Minimax M2.1
-   Gemini 3 Pro

---

## [Set a default](#set-a-default)

To set a default model:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "model": "lmstudio/google/gemma-3n-e4b"}
```

The full ID is `provider_id/model_id`.

---

## [Configure models](#configure-models)

You can globally configure a model's options:

opencode.jsonc

```
{  "$schema": "https://opencode.ai/config.json",  "provider": {    "openai": {      "models": {        "gpt-5": {          "options": {            "reasoningEffort": "high"          }        }      }    }  }}
```

---

## [Variants](#variants)

Many models support multiple variants with different configurations.

### [Built-in variants](#built-in-variants)

OpenCode ships with default variants for many providers:

**Anthropic**: `high` (default), `max`

**OpenAI**: `none`, `minimal`, `low`, `medium`, `high`, `xhigh`

**Google**: `low`, `high`

### [Custom variants](#custom-variants)

You can override existing variants or add your own:

opencode.jsonc

```
{  "$schema": "https://opencode.ai/config.json",  "provider": {    "opencode": {      "models": {        "gpt-5": {          "variants": {            "thinking": {              "reasoningEffort": "high"            }          }        }      }    }  }}
```

### [Cycle variants](#cycle-variants)

Use the keybind `variant_cycle` to quickly switch between variants.

---

## [Loading models](#loading-models)

When OpenCode starts up, it checks for models in this priority order:

1.  The `--model` or `-m` command line flag
2.  The model in the OpenCode config
3.  The last used model
4.  The first model using internal priority

Last updated: Apr 27, 2026
