# Hermes Installation Guide

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- **Hermes docs/config assumptions:** 2026-05 baseline
- **Last validated:** 2026-05-11

This guide walks through installing Hermes from scratch on different operating systems. Hermes is the foundation that enables symbiotic AI partnerships.

## What is Hermes?

Hermes is an AI gateway that provides:
- Multi-model AI access (Ollama Cloud, OpenAI, local models)
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

This installs Hermes globally via npm:

```bash
# Install Hermes globally
npm install -g hermes

# Verify installation
hermes --version

# Show available commands
hermes --help
```

**Pros:** Simple, automatic updates, clean uninstall
**Cons:** Requires npm/Node.js setup

### Method 2: Git Clone Installation

For development or customization:

```bash
# Clone the repository
git clone https://github.com/nousresearch/hermes-agent.git
cd hermes

# Install dependencies
npm install

# Build the project
npm run build

# Create global symlink (optional)
npm link

# Verify installation
./bin/hermes.js --version
```

**Pros:** Full source access, customization possible
**Cons:** More complex, manual updates

## Platform-Specific Setup

### Linux (Ubuntu/Debian)

```bash
# Update system packages
sudo apt update

# Install Node.js 18+ and npm
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git if not present
sudo apt-get install -y git

# Install Hermes
npm install -g hermes

# Verify installation
hermes --version
```

### macOS

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js and npm
brew install node

# Install Git if not present
brew install git

# Install Hermes
npm install -g hermes

# Verify installation
hermes --version
```

### Windows

**Option A: Using Node.js Installer**

1. Download Node.js from https://nodejs.org/ (LTS version)
2. Run the installer (includes npm automatically)
3. Open Command Prompt or PowerShell as Administrator
4. Run: `npm install -g hermes`
5. Verify: `hermes --version`

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
# Pull Hermes Docker image (if available)
docker pull hermes/hermes:latest

# Or build from source
git clone https://github.com/nousresearch/hermes-agent.git
cd hermes
docker build -t hermes .

# Run Hermes in container
docker run -d \
  --name hermes \
  -p 3000:3000 \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/workspace:/app/workspace \
  hermes
```

## Initial Configuration

### 1. Create Configuration Directory

```bash
# Create Hermes config directory
mkdir -p ~/.hermes

# Create initial workspace
mkdir -p ~/.hermes/workspace
```

### 2. Generate Initial Config

```bash
# Generate default configuration
# Create ~/.hermes/config.yaml manually (or from your own template)

# This creates ~/.hermes/config.yaml
```

### 3. Basic Configuration

Edit `~/.hermes/config.yaml`:

```yaml
model:
  default: glm-5.1:cloud
  provider: custom:ollama

providers: {}

gateway:
  host: localhost
  port: 3000
  bind: 127.0.0.1

agent:
  workspace: /home/username/.hermes/workspace
```

## Add AI Model Provider

You'll need API access to at least one AI provider:

### Ollama Cloud (Recommended)

```yaml
model:
  default: glm-5.1:cloud
  provider: custom:ollama

providers: {}
```

Ollama Cloud models (GLM-5.1, Kimi K2.6, DeepSeek V4 Pro, Qwen 3.5)
are available automatically with the `custom:ollama` provider.

**Getting Ollama Cloud API key:**
1. Go to https://ollama.com/cloud
2. Create account and add billing
3. Generate API key in settings
4. Add to configuration

### OpenAI Alternative

```yaml
model:
  default: gpt-5.4
  provider: openai-codex
```

### Local Models (Ollama)

For privacy and cost savings:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install | sh

# Pull a model
ollama pull qwen2.5:3b
```

Add to `~/.hermes/config.yaml`:

```yaml
providers:
  ollama:
    type: openai
    base_url: http://127.0.0.1:11434/v1
    api_key: ollama
    models:
      - qwen2.5:3b
```

## Start Hermes

### Method 1: Direct Run

```bash
# Start Hermes gateway
hermes gateway start

# Check status
hermes status

# View logs
hermes logs
```

### Method 2: System Service (Linux)

```bash
# Install as systemd service
sudo hermes gateway install

# Enable auto-start
sudo systemctl enable hermes

# Start service
sudo systemctl start hermes

# Check status
sudo systemctl status hermes
```

### Method 3: Development Mode

```bash
# Start with verbose logging
hermes gateway start --verbose

# Or with file watching for config changes
# Config watch mode may vary by version; run: hermes gateway --help
```

## Verify Installation

### Check Gateway Status

```bash
hermes status
```

Should show:
- Gateway running on configured port
- At least one agent configured
- Model provider accessible

### Test Basic Interaction

```bash
# Send test message to agent
# CLI chat command varies by version; use your configured channel/UI for a first test message
```

### Web Interface (if enabled)

Visit http://localhost:3000 in your browser to access the web interface.

## Post-Installation Setup

### 1. Set Up Memory System

Follow the [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md) guide to enable local memory.

### 2. Configure Identity Files

Use templates from [examples/](examples/) to create:
- `~/.hermes/workspace/IDENTITY.md`
- `~/.hermes/workspace/SOUL.md`
- `~/.hermes/workspace/USER.md`
- `~/.hermes/workspace/BOOTSTRAP.md`

### 3. Add Communication Channels

Configure Discord, Telegram, or other channels in `~/.hermes/config.yaml`:

```yaml
channels:
  discord:
    enabled: true
    token: your-discord-bot-token
    targetAgent: main
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

# Kill the process or change Hermes port
# Edit ~/.hermes/config.yaml:
gateway:
  port: 3001
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
# Config file is typically ~/.hermes/config.yaml (verify via: hermes config --help)

# Validate JSON syntax
cat ~/.hermes/config.yaml | python3 -m json.tool

# Reset to defaults
# Reset manually: back up then replace your config file from a known-good template
```

### API Key Issues

```bash
# Test API key manually
curl -H "Authorization: Bearer your-api-key" \
     -H "Content-Type: application/json" \
     https://api.openai.com/v1/models (or Ollama Cloud)

# Check Hermes logs for API errors
hermes logs --level error
```

## Updating Hermes

### NPM Installation

```bash
# Update to latest version
npm update -g hermes

# Check version
hermes --version
```

### Git Installation

```bash
cd hermes
git pull origin main
npm install
npm run build
```

## Security Considerations

### File Permissions

```bash
# Secure config directory
chmod 700 ~/.hermes
chmod 600 ~/.hermes/config.yaml
```

### API Key Security

- Never commit API keys to git repositories
- Use environment variables for production deployments
- Rotate API keys regularly
- Monitor API usage for unexpected activity

### Network Security

- Keep Hermes behind firewall if running on server
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
export HERMES_PORT=3000
export HERMES_HOST=localhost
export ANTHROPIC_API_KEY=your-key
export HERMES_WORKSPACE=/path/to/workspace

hermes gateway start
```

### Multiple Instances

```bash
# Run multiple Hermes instances
HERMES_PORT=3001 HERMES_CONFIG=~/.hermes/config1.json hermes gateway start &
HERMES_PORT=3002 HERMES_CONFIG=~/.hermes/config2.json hermes gateway start &
```

## Next Steps

After successful installation:

1. **Follow Configuration Guide** - [HERMES-CONFIGURATION.md](HERMES-CONFIGURATION.md)
2. **Set Up Local Memory** - [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md)
3. **Read Philosophy Guide** - [docs/reference/KUU-AI-SETUP-GUIDE.md](docs/reference/KUU-AI-SETUP-GUIDE.md)
4. **Customize Identity** - Use [examples/](examples/) templates
5. **Test Interaction** - Start building your AI partnership!

## Getting Help

- **Hermes Documentation**: Check built-in help with `hermes --help` and `hermes <subcommand> --help`
- **GitHub Issues**: https://github.com/nousresearch/hermes-agent/issues
- **Community**: Join Hermes Discord or forums
- **Configuration Problems**: Review [docs/reference/FAQ.md](docs/reference/FAQ.md)

---

*Once Hermes is running, you're ready to build a symbiotic AI partnership! The technical foundation enables the relationship magic.* 🌙
