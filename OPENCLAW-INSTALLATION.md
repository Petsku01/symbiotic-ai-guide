# OpenClaw Installation Guide

This guide walks through installing OpenClaw from scratch on different operating systems. OpenClaw is the foundation that enables symbiotic AI partnerships.

## What is OpenClaw?

OpenClaw is an AI gateway that provides:
- Multi-model AI access (Anthropic, OpenAI, local models)
- Persistent memory and identity systems
- Tool access for file operations, web browsing, system commands
- Multi-channel communication (Discord, Telegram, etc.)
- Agent-to-agent collaboration capabilities

## Prerequisites

- **Node.js 18+** (Node.js runtime)
- **Git** (for installation and updates)
- **Terminal/Command Line** access
- **Text Editor** (VS Code, nano, vim, etc.)

## Installation Methods

### Method 1: NPM Installation (Recommended)

This installs OpenClaw globally via npm:

```bash
# Install OpenClaw globally
npm install -g openclaw

# Verify installation
openclaw --version

# Show available commands
openclaw help
```

**Pros:** Simple, automatic updates, clean uninstall  
**Cons:** Requires npm/Node.js setup

### Method 2: Git Clone Installation

For development or customization:

```bash
# Clone the repository
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# Install dependencies
npm install

# Build the project
npm run build

# Create global symlink (optional)
npm link

# Verify installation
./bin/openclaw.js --version
```

**Pros:** Full source access, customization possible  
**Cons:** More complex, manual updates

## Platform-Specific Setup

### Linux (Ubuntu/Debian)

```bash
# Update system packages
sudo apt update

# Install Node.js 18+ and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git if not present
sudo apt-get install -y git

# Install OpenClaw
npm install -g openclaw

# Verify installation
openclaw --version
```

### macOS

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js and npm
brew install node

# Install Git if not present
brew install git

# Install OpenClaw
npm install -g openclaw

# Verify installation
openclaw --version
```

### Windows

**Option A: Using Node.js Installer**

1. Download Node.js from https://nodejs.org/ (LTS version)
2. Run the installer (includes npm automatically)
3. Open Command Prompt or PowerShell as Administrator
4. Run: `npm install -g openclaw`
5. Verify: `openclaw --version`

**Option B: Using Windows Subsystem for Linux (WSL)**

```bash
# Enable WSL and install Ubuntu
wsl --install

# Restart and open Ubuntu terminal
# Follow Linux installation steps above
```

### Docker Installation

For containerized deployment:

```bash
# Pull OpenClaw Docker image (if available)
docker pull openclaw/openclaw:latest

# Or build from source
git clone https://github.com/openclaw/openclaw.git
cd openclaw
docker build -t openclaw .

# Run OpenClaw in container
docker run -d \
  --name openclaw \
  -p 3000:3000 \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/workspace:/app/workspace \
  openclaw
```

## Initial Configuration

### 1. Create Configuration Directory

```bash
# Create OpenClaw config directory
mkdir -p ~/.openclaw

# Create initial workspace
mkdir -p ~/.openclaw/workspace
```

### 2. Generate Initial Config

```bash
# Generate default configuration
openclaw config init

# This creates ~/.openclaw/openclaw.json
```

### 3. Basic Configuration

Edit `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "host": "localhost",
    "port": 3000,
    "bind": "127.0.0.1"
  },
  "agents": {
    "defaults": {
      "workspace": "/home/username/.openclaw/workspace"
    },
    "list": [
      {
        "id": "main",
        "name": "Assistant",
        "default": true
      }
    ]
  },
  "models": {
    "providers": {}
  }
}
```

## Add AI Model Provider

You'll need API access to at least one AI provider:

### Anthropic (Recommended)

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.anthropic.com",
        "apiKey": "your-api-key-here",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "claude-sonnet-4-20250514",
            "name": "Claude Sonnet 4",
            "cost": {
              "input": 3,
              "output": 15
            },
            "contextWindow": 200000,
            "maxTokens": 8192
          }
        ]
      }
    }
  }
}
```

**Getting Anthropic API key:**
1. Go to https://console.anthropic.com/
2. Create account and add billing
3. Generate API key in settings
4. Add to configuration

### OpenAI Alternative

```json
{
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "apiKey": "your-openai-api-key",
        "api": "openai-completions",
        "models": [
          {
            "id": "gpt-4o",
            "name": "GPT-4O",
            "cost": {
              "input": 2.5,
              "output": 10
            },
            "contextWindow": 128000,
            "maxTokens": 4096
          }
        ]
      }
    }
  }
}
```

### Local Models (Ollama)

For privacy and cost savings:

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull a model
ollama pull qwen2.5:3b

# Add to OpenClaw config
```

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:11434/v1",
        "apiKey": "ollama",
        "api": "openai-completions",
        "models": [
          {
            "id": "qwen2.5:3b",
            "name": "Local Qwen 3B",
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
}
```

## Start OpenClaw

### Method 1: Direct Run

```bash
# Start OpenClaw gateway
openclaw gateway start

# Check status
openclaw status

# View logs
openclaw gateway logs
```

### Method 2: System Service (Linux)

```bash
# Install as systemd service
sudo openclaw gateway install

# Enable auto-start
sudo systemctl enable openclaw

# Start service
sudo systemctl start openclaw

# Check status
sudo systemctl status openclaw
```

### Method 3: Development Mode

```bash
# Start with verbose logging
openclaw gateway start --verbose

# Or with file watching for config changes
openclaw gateway start --watch
```

## Verify Installation

### Check Gateway Status

```bash
openclaw status
```

Should show:
- Gateway running on configured port
- At least one agent configured
- Model provider accessible

### Test Basic Interaction

```bash
# Send test message to agent
openclaw chat "Hello, can you introduce yourself?"
```

### Web Interface (if enabled)

Visit http://localhost:3000 in your browser to access the web interface.

## Post-Installation Setup

### 1. Set Up Memory System

Follow the [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md) guide to enable local memory.

### 2. Configure Identity Files

Use templates from [examples/](examples/) to create:
- `~/.openclaw/workspace/IDENTITY.md`
- `~/.openclaw/workspace/SOUL.md`
- `~/.openclaw/workspace/USER.md`
- `~/.openclaw/workspace/BOOTSTRAP.md`

### 3. Add Communication Channels

Configure Discord, Telegram, or other channels as needed:

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "your-discord-bot-token",
      "targetAgent": "main"
    }
  }
}
```

## Common Installation Issues

### Permission Errors

```bash
# Fix npm permission issues (Linux/Mac)
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Or use npm prefix
npm config set prefix ~/.local
export PATH=~/.local/bin:$PATH
```

### Port Already in Use

```bash
# Find what's using port 3000
sudo lsof -i :3000

# Kill the process or change OpenClaw port
# Edit ~/.openclaw/openclaw.json:
{
  "gateway": {
    "port": 3001
  }
}
```

### Node.js Version Issues

```bash
# Check Node.js version
node --version

# Should be 18.0.0 or higher
# Update if needed using nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

### Configuration Not Loading

```bash
# Check config file location
openclaw config path

# Validate JSON syntax
cat ~/.openclaw/openclaw.json | python -m json.tool

# Reset to defaults
openclaw config init --force
```

### API Key Issues

```bash
# Test API key manually
curl -H "Authorization: Bearer your-api-key" \
     -H "Content-Type: application/json" \
     https://api.anthropic.com/v1/models

# Check OpenClaw logs for API errors
openclaw gateway logs | grep -i error
```

## Updating OpenClaw

### NPM Installation

```bash
# Update to latest version
npm update -g openclaw

# Check version
openclaw --version
```

### Git Installation

```bash
cd openclaw
git pull origin main
npm install
npm run build
```

## Security Considerations

### File Permissions

```bash
# Secure config directory
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
```

### API Key Security

- Never commit API keys to git repositories
- Use environment variables for production deployments
- Rotate API keys regularly
- Monitor API usage for unexpected activity

### Network Security

- Keep OpenClaw behind firewall if running on server
- Use HTTPS in production environments
- Consider VPN access for remote management
- Regular security updates for Node.js and dependencies

## Advanced Installation Options

### Reverse Proxy Setup (Nginx)

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Environment Variables

```bash
# Set via environment instead of config file
export OPENCLAW_PORT=3000
export OPENCLAW_HOST=localhost
export ANTHROPIC_API_KEY=your-key
export OPENCLAW_WORKSPACE=/path/to/workspace

openclaw gateway start
```

### Multiple Instances

```bash
# Run multiple OpenClaw instances
OPENCLAW_PORT=3001 OPENCLAW_CONFIG=~/.openclaw/config1.json openclaw gateway start &
OPENCLAW_PORT=3002 OPENCLAW_CONFIG=~/.openclaw/config2.json openclaw gateway start &
```

## Next Steps

After successful installation:

1. **Follow Configuration Guide** - [OPENCLAW-CONFIGURATION.md](OPENCLAW-CONFIGURATION.md)
2. **Set Up Local Memory** - [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md)  
3. **Read Philosophy Guide** - [KUU-AI-SETUP-GUIDE.md](KUU-AI-SETUP-GUIDE.md)
4. **Customize Identity** - Use [examples/](examples/) templates
5. **Test Interaction** - Start building your AI partnership!

## Getting Help

- **OpenClaw Documentation**: Check built-in help with `openclaw help`
- **GitHub Issues**: https://github.com/openclaw/openclaw/issues
- **Community**: Join OpenClaw Discord or forums
- **Configuration Problems**: Review [FAQ.md](FAQ.md)

---

*Once OpenClaw is running, you're ready to build a symbiotic AI partnership! The technical foundation enables the relationship magic.* 🌙