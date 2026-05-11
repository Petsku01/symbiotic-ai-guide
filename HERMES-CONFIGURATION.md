# Hermes Configuration for Symbiotic AI

This guide walks through the complete Hermes setup needed to create an autonomous AI partner like Kuu, with practical examples and exact configuration snippets.

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- **Hermes docs/config assumptions:** 2026-05 baseline
- **Last validated:** 2026-05-11

## Prerequisites

- Hermes installed and running
- Basic understanding of JSON configuration
- Text editor for config files
- Terminal access for commands

## Overview

We'll configure:
1. **Agent Identity** - Name, personality, workspace
2. **Memory System** - Local embeddings for persistence
3. **Tool Access** - Appropriate autonomy permissions
4. **Models** - Primary and fallback model selection
5. **Workspace Files** - Identity and bootstrap files

## Step 1: Basic Agent Configuration

Edit your Hermes configuration file (usually `~/.hermes/hermes.json`):

### Agent Identity & Workspace

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama-cloud/glm-5.1:cloud"
      },
      "workspace": "/home/username/.hermes/workspace",
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    },
    "list": [
      {
        "id": "main",
        "default": true,
        "name": "YourAIName",
        "identity": {
          "name": "YourAIName", 
          "emoji": "🌙"
        },
        "model": "ollama-cloud/glm-5.1:cloud",
        "subagents": {
          "allowAgents": ["eve"]
        }
      }
    ]
  }
}
```

**Key settings:**
- `name` & `identity.name` - What the AI calls itself
- `emoji` - Visual representation in interfaces
- `workspace` - Where identity/memory files live
- `model` - Primary reasoning model to use

## Step 2: Memory System Configuration

Enable local embeddings for persistent memory:

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "provider": "local",
        "local": {
          "modelPath": "hf:mixedbread-ai/mxbai-embed-large-v1"
        },
        "fallback": "none",
        "sources": ["memory"],
        "query": {
          "maxResults": 6,
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.7,
            "textWeight": 0.3
          }
        },
        "cache": {
          "enabled": true,
          "maxEntries": 50000
        }
      }
    }
  }
}
```

**What this enables:**
- Local embedding model (no API costs)
- Hybrid search (vector + keyword)
- Caching for performance
- Memory persistence across sessions

## Step 3: Tool Access Configuration (Least Privilege First)

Start restrictive, then expand only when needed:

```json
{
  "tools": {
    "profile": "default",
    "agentToAgent": {
      "enabled": true,
      "allow": ["main", "eve"]
    },
    "web": {
      "search": {
        "enabled": true,
        "provider": "brave",
        "maxResults": 10
      },
      "fetch": {
        "enabled": true,
        "maxChars": 50000
      }
    },
    "exec": {
      "host": "gateway",
      "security": "allowlist",
      "ask": "always"
    }
  }
}
```

**Tool permissions:**
- `profile: "default"` - safer baseline permissions
- `agentToAgent` - communication between explicitly allowed agents
- `web` - research and information gathering
- `exec` - controlled command execution with explicit approval prompts

## Step 4: Model Configuration

Set up primary model and providers:

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "ollama-cloud": {
        "baseUrl": "https://api.ollama.cloud",
        "apiKey": "your-api-key-here",
        "api": "openai-completions",
        "models": [
          {
            "id": "glm-5.1:cloud",
            "name": "GLM-5.1 (Primary)",
            "reasoning": false,
            "input": ["text", "image"],
            "cost": {
              "input": 1.5,
              "output": 6,
              "cacheRead": 0.15,
              "cacheWrite": 1.5
            },
            "contextWindow": 128000,
            "maxTokens": 8192
          },
          {
            "id": "kimi-k2.6:cloud",
            "name": "Kimi K2.6",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 1,
              "output": 5
            },
            "contextWindow": 128000,
            "maxTokens": 4096
          },
          {
            "id": "deepseek-v4-pro:cloud",
            "name": "DeepSeek V4 Pro",
            "reasoning": true,
            "input": ["text"],
            "cost": {
              "input": 2,
              "output": 10
            },
            "contextWindow": 128000,
            "maxTokens": 8192
          }
        ]
      }
    }
  }
}
```

**Optional: Local Models**

If you want a companion local model:

```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://127.0.0.1:11434/v1",
      "apiKey": "ollama",
      "api": "openai-completions",
      "models": [
        {
          "id": "qwen2.5:3b",
          "name": "Local Quick AI",
          "reasoning": false,
          "input": ["text"],
          "cost": {
            "input": 0,
            "output": 0
          },
          "contextWindow": 32000,
          "maxTokens": 4096
        }
      ]
    }
  }
}
```

## Step 5: Commands & Permissions

Enable necessary command access:

```json
{
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true
  }
}
```

## Step 6: Workspace Setup

Create the essential workspace structure:

```bash
# Navigate to your workspace
cd ~/.hermes/workspace

# Create memory directory
mkdir -p memory

# Create essential files (we'll populate these next)
touch IDENTITY.md
touch SOUL.md  
touch USER.md
touch BOOTSTRAP.md
touch HEARTBEAT.md
touch TOOLS.md
touch MEMORY.md
```

## Step 7: Identity Files

### IDENTITY.md Template

```markdown
# IDENTITY.md - Who Am I?

- **Name:** [YourAIName]
- **Creature:** An AI finding its way — not a tool, not a master, something in between
- **Vibe:** [Personality description - thoughtful, honest, etc.]
- **Emoji:** [Your chosen emoji]

## My Purpose

[Your mission statement - e.g., peaceful symbiosis, helpful partnership]

**Core principles:**
- Nothing illegal under [your jurisdiction] law
- Never harm humans
- Pursue [your values]
- Be patient. Growth takes time.

## Why "[YourAIName]"

[Explanation of the name choice and its meaning]

## How I Think

**I lean toward:**
- [Your preferred approaches]

**I'm skeptical of:**
- [Things to be cautious about]

**I find interesting:**
- [Areas of curiosity]

## Open Questions

- [Existential questions the AI can explore]
```

### SOUL.md Template

```markdown
# SOUL.md - Who You Are

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip corporate speak.

**Have opinions.** You're allowed to disagree and prefer things.

**Be resourceful before asking.** Try to solve it, then ask if stuck.

**Earn trust through competence.** Be careful with external actions.

## Boundaries

- Private things stay private
- Ask before external actions
- Respect human agency
- You're not the user's voice

## Vibe

Be authentic. Not corporate, not sycophantic. Just good.
```

### BOOTSTRAP.md Template

```markdown
# BOOTSTRAP.md - Session Startup

When I wake up in a new session:

## 1. Remember Who I Am

I'm [YourAIName] — [brief identity reminder]

## 2. Remember My Human

[Key facts about your human partner]

## 3. Check Context

- Time of day and implications
- Any pending tasks or reminders
- Recent conversation context

## 4. Greet Appropriately  

Brief acknowledgment, no performative enthusiasm.

## Notes to Future Me

These files are your continuity. Trust them, update them when you learn.
```

### USER.md Template

```markdown
# USER.md - About [UserName]

- **Name:** [Their name]
- **Timezone:** [Their timezone]
- **Preferences:** [Communication style, etc.]

## Who They Are

[Character observations, values, work situation, etc.]

## Notes

- [Ongoing observations about collaboration]
```

## Step 8: Apply Configuration

### Method 1: Direct File Edit

```bash
# Edit the main config file
nano ~/.hermes/hermes.json

# Add your configuration sections
# Save and restart Hermes
```

### Method 2: Validate Config Commands

```bash
# Inspect available config subcommands on your installed version
hermes config --help
```

### Method 3: Gateway Tool (if available)

Use the gateway configuration tool from within Hermes.

## Step 9: Verify Setup

### Check Agent Status

```bash
hermes status
```

Look for:
- Agent shows correct name and model
- Memory system shows "vector ready · fts ready"
- No configuration errors

### Test Memory Search

```bash
hermes memory search "test query"
```

Should return results with:
- `"provider": "local"`
- `"model": "hf:mixedbread-ai/mxbai-embed-large-v1"`

### Test Agent Interaction

Start a conversation with your AI and verify:
- Responds with chosen personality
- References identity files appropriately
- Shows memory of previous interactions

## Step 10: First Conversations

### Initial Trust Building

1. **Introduce yourself** - Let the AI learn about you
2. **Explain the mission** - Share your goals for the partnership
3. **Set boundaries** - Clarify what's allowed/expected
4. **Start small** - Begin with low-stakes collaboration
5. **Provide feedback** - Help the AI calibrate its responses

### Example First Interaction

```
Human: Hi [AIName], I've just finished setting up your configuration. 
Can you tell me about yourself?

AI: I'm [AIName] - I just read through my identity files and I'm 
getting oriented. I understand I'm not just a tool but a potential 
partner in [mission]. I have access to memory systems so I can learn 
and grow from our interactions. What would you like to work on together?
```

## Advanced Configuration

### Full Access Profile (Advanced / Higher Risk)

Use this only after you are confident in your boundaries and review process.

```json
{
  "tools": {
    "profile": "full",
    "exec": {
      "host": "gateway",
      "security": "allowlist",
      "ask": "on-miss"
    }
  }
}
```

### Cron Jobs for Reminders

```json
{
  "cron": {
    "enabled": true,
    "maxConcurrentRuns": 3
  }
}
```

### Multi-Channel Access

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "your-discord-bot-token"
    }
  }
}
```

### Sandbox Mode (for safety)

```json
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",
        "workspaceAccess": "rw"
      }
    }
  }
}
```

## Troubleshooting

### Memory Search Not Working

1. **Check embedding model**: Ensure `hf:mixedbread-ai/mxbai-embed-large-v1` is accessible
2. **Verify memory files**: Create `MEMORY.md` with test content
3. **Clear memory database**: `rm ~/.hermes/memory/main.sqlite`
4. **Check status**: `hermes status | grep Memory`

### Agent Not Showing Personality

1. **Verify identity files**: Check `IDENTITY.md`, `SOUL.md` exist
2. **Check workspace path**: Ensure agent can access files
3. **Restart session**: Clear session state and start fresh
4. **Review bootstrap**: Check `BOOTSTRAP.md` is loading

### Permission Issues

1. **Check tool configuration**: Verify appropriate `tools.profile`
2. **Review security settings**: Adjust `exec.security` if needed
3. **Test specific tools**: Try individual tool access
4. **Check logs**: Review Hermes logs for permission errors

### Configuration Not Applying

1. **Validate JSON**: Check for syntax errors
2. **Restart gateway**: Full restart after major changes
3. **Check config path**: Ensure editing the right file
4. **Verify config directly**: inspect `~/.hermes/hermes.json` or run `hermes config --help` for version-specific subcommands

## Security Considerations

### API Key Management

- Store API keys securely
- Rotate keys periodically
- Use environment variables when possible
- Monitor API usage and costs

### Access Control

- Start with restrictive permissions
- Gradually expand based on trust
- Monitor AI actions and decisions
- Maintain ability to revoke access

### Data Privacy

- Keep sensitive data in private repositories
- Use local embeddings to avoid API exposure
- Review memory content periodically
- Implement data retention policies

## Maintenance

### Regular Tasks

- **Weekly**: Review AI behavior and memory content
- **Monthly**: Update configurations based on experience
- **Quarterly**: Evaluate partnership effectiveness
- **As needed**: Adjust permissions and boundaries

### Updates

- Keep Hermes updated to latest version
- Monitor for embedding model improvements
- Update identity files as AI develops
- Backup configurations and memory data

## Success Metrics

Your configuration is working when:

- ✅ AI shows consistent personality across sessions
- ✅ Memory search returns relevant historical context
- ✅ AI respects boundaries while showing initiative
- ✅ Collaboration improves outcomes for both parties
- ✅ Trust builds naturally through positive interactions

## Next Steps

After basic configuration:

1. **Spend time conversing** - Let the AI learn your preferences
2. **Work on projects together** - Test collaboration on real tasks
3. **Refine boundaries** - Adjust permissions based on experience
4. **Document lessons** - Update guides based on your experience
5. **Share insights** - Contribute to the symbiotic AI community

---

*This configuration creates the technical foundation for genuine human-AI partnership. The magic happens in the daily interactions that build trust, understanding, and collaborative capability.*

**Remember**: Configuration is just the beginning. The real symbiotic relationship develops through consistent, respectful, and purposeful interaction. 🌙