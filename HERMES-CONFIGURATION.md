# Hermes Configuration for Symbiotic AI

This guide walks through the complete Hermes setup needed to create an autonomous AI partner like Kuu, with practical examples and exact configuration snippets.

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- **Hermes docs/config assumptions:** 2026-07 baseline
- **Last validated:** 2026-07-01

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

Edit your Hermes configuration file (usually `~/.hermes/config.yaml`):

### Agent Identity & Workspace

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama-cloud/glm-5.2:cloud"
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
        "model": "ollama-cloud/glm-5.2:cloud",
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

Set up primary model and providers in `~/.hermes/config.yaml`:

```yaml
config_version: 30

model:
  default: glm-5.2:cloud
  provider: custom:ollama

providers: {}
```

Ollama Cloud models (GLM-5.2, Kimi K2.6, DeepSeek V4 Pro, Qwen 3.5) are
available automatically when the Ollama Cloud provider is configured.

**Optional: Local Models**

If you want a companion local model via Ollama:

```yaml
# Add under providers: in ~/.hermes/config.yaml
ollama:
  type: openai
  base_url: http://127.0.0.1:11434/v1
  api_key: ollama
  models:
    - qwen2.5:3b
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
nano ~/.hermes/config.yaml

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

## Advanced Configuration: v0.17.0 Features

Hermes v0.17.0 (config_version 30) introduced several subsystems that extend configuration beyond the basics above.

### Task Mode (agent.system_prompt)

Set a system prompt to put the agent into a focused task mode:

```yaml
agent:
  system_prompt: |
    You are a focused task agent. Complete the assigned work efficiently.
    Ask for clarification only when truly stuck.
```

### Security and Privacy

```yaml
security:
  redact_secrets: true    # Redact API keys and secrets in logs (default: true)

privacy:
  redact_pii: false        # Redact personally identifiable info (default: false)

approvals:
  mode: manual             # Options: manual, smart, off (default: manual)
```

**Approval modes:**
- `manual` - Prompt for approval on each action requiring it
- `smart` - Auto-approve safe operations, prompt for risky ones
- `off` - No approval prompts (use with caution)

### MCP Servers

Model Context Protocol (MCP) servers provide tool integrations:

```bash
# Add an MCP server
hermes mcp add <name> <command> [args...]

# List configured MCP servers
hermes mcp list

# Test an MCP server connection
hermes mcp test <name>

# Remove an MCP server
hermes mcp remove <name>
```

### Skills

Skills are installable capability modules that extend agent abilities:

```bash
# List available skills
hermes skills list

# Install a skill
hermes skills install <name>

# Configure a skill
hermes skills config <name>
```

### Profiles

Profiles allow isolated configurations for different use cases (work, personal, experiments):

```bash
# Create a new profile
hermes profile create <name>

# Switch to a profile
hermes profile use <name>

# List all profiles
hermes profile list
```

Each profile has its own config, workspace, and credentials.

### Credential Pools

Manage multiple provider credentials without environment variables:

```bash
# Add credentials interactively
hermes auth add

# List configured credentials
hermes auth list

# Remove credentials
hermes auth remove <name>
```

### Fallback Providers

Automatic failover between AI providers for reliability:

```bash
# Add a fallback provider
hermes fallback add <provider> <model>

# Remove a fallback provider
hermes fallback remove <provider>

# List fallback chain
hermes fallback list
```

### Dashboard

The web-based Dashboard provides a browser UI alternative to `hermes tui`:

```bash
# Open the dashboard in your browser
hermes dashboard
```

The Dashboard runs at http://localhost:9119 when the gateway is active.

### Curator

The Curator performs automated memory and workspace maintenance:

```bash
# Check curator status
hermes curator status

# Run curator manually
hermes curator run
```

### Cron Jobs

Scheduled task execution for recurring operations:

```bash
# List cron jobs
hermes cron list

# Create a new cron job
hermes cron create

# Edit an existing cron job
hermes cron edit <name>
```

### Gateway: Multi-Channel Support

The Hermes Gateway supports 20+ communication platforms including Telegram, Discord, Slack, WhatsApp, Signal, Email, SMS, Matrix, and more. Configure channels in `~/.hermes/config.yaml`:

```yaml
channels:
  telegram:
    enabled: true
    token: your-telegram-bot-token
  discord:
    enabled: true
    token: your-discord-bot-token
```

See `hermes gateway --help` for the full list of supported platforms.

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
4. **Verify config directly**: inspect `~/.hermes/config.yaml` or run `hermes config --help` for version-specific subcommands

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
