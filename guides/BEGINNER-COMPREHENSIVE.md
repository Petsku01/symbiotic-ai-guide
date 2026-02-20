# OpenClaw Setup Guide for Ubuntu 24.04 LTS (WSL2)
*From "Never heard of this" to "Working AI Assistant"*

---

## What Is OpenClaw?

**OpenClaw is an open-source AI assistant that runs on your computer.** Unlike ChatGPT or Siri, your conversations stay private and you can customize how it works.

Think of it as your personal AI that:
- Runs locally (your data stays on your machine)
- Works with multiple AI providers (Anthropic, OpenAI, Google, local models)
- Connects to Discord, email, calendar, and other services
- Costs only what you use (no monthly subscription)

### How OpenClaw Works (Architecture)

OpenClaw has two main parts:

```
┌─────────────────────────────────────────────────────────────┐
│  Your Computer (Ubuntu 24.04 WSL2)                          │
│                                                             │
│   ┌─────────────┐         ┌──────────────────────────────┐ │
│   │ openclaw    │ ──────► │ OpenClaw Gateway             │ │
│   │ tui         │         │ (background service)         │ │
│   │ (CLI tool)  │         │                              │ │
│   └─────────────┘         │ • Manages AI connections     │ │
│                           │ • Handles authentication     │ │
│         ▲                 │ • Routes requests to Claude  │ │
│         │                 │ • Manages integrations       │ │
│   You type here           └──────────────────────────────┘ │
│                                      │                      │
└──────────────────────────────────────│──────────────────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │ AI Provider API  │
                              │ (Anthropic, etc) │
                              └──────────────────┘
```

- **Gateway**: A daemon (background service) that must be running for OpenClaw to work
- **CLI Tools**: Commands like `openclaw tui` that you use to interact with the AI

**Realistic time:** 20-40 minutes  
**Realistic cost:** Light usage ~$3-8/month, Heavy usage ~$15-25/month (pay-per-use)

---

## Before You Start - Prerequisites Check

**You will need:**
- [ ] Windows 10/11 with WSL2 and Ubuntu 24.04 LTS installed
- [ ] Stable internet connection (~300MB download)
- [ ] Credit/debit card (for API provider signup)
- [ ] Phone number (for API verification)
- [ ] 20-40 minutes of focused time

**If WSL2/Ubuntu isn't set up yet:**
```powershell
# Run in Windows PowerShell as Administrator:
wsl --install -d Ubuntu-24.04
```
Then restart Windows and set up your Ubuntu username/password.

---

## Step 1: Open Ubuntu Terminal

**From Windows:**
1. Press `Windows key`
2. Type `Ubuntu` 
3. Click "Ubuntu 24.04 LTS"

**Or from any terminal:**
```powershell
wsl -d Ubuntu-24.04
```

**Verify you're in Ubuntu:**
```bash
lsb_release -a
```

You should see:
```
Distributor ID: Ubuntu
Description:    Ubuntu 24.04 LTS
```

---

# Phase 1: Installing Node.js
*"The foundation everything else needs"*

## Install Node.js on Ubuntu 24.04

Ubuntu 24.04 includes Node.js in its repositories, but we'll use NodeSource for the latest LTS version:

```bash
# Update package lists
sudo apt update

# Install prerequisites
sudo apt install -y ca-certificates curl gnupg

# Add NodeSource repository for Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs
```

**What these commands do:**
- `sudo apt update` - Refreshes the list of available packages
- `curl ... | sudo -E bash -` - Downloads and runs the NodeSource setup script
- `sudo apt install -y nodejs` - Installs Node.js and npm

## Verify Node.js Works

```bash
node --version
```

**Success looks like:**
```
v22.14.0
```
*(Your exact version may differ - anything v20+ is fine)*

```bash
npm --version
```

**Success looks like:**
```
10.9.2
```

**If "command not found":**
1. Close and reopen your Ubuntu terminal
2. Try again
3. If still failing, run `sudo apt install -y nodejs npm` directly

**STOP: Do not continue until both `node --version` and `npm --version` show version numbers.**

---

# Phase 2: Installing OpenClaw
*"Getting the actual AI assistant software"*

## Install OpenClaw

```bash
sudo npm install -g openclaw
```

**What you'll see:**
- Lines of text showing packages being downloaded
- Progress indicators
- Takes 1-3 minutes depending on internet speed

**If you see permission errors:**
```bash
# Fix npm global permissions (alternative approach)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
npm install -g openclaw
```

## Verify OpenClaw Installed

```bash
openclaw --version
```

**Success looks like:**
```
2026.2.17
```

**If "command not found":**
1. Close and reopen terminal
2. Try `which openclaw` to see if it's in your PATH
3. If using the npm-global fix above, ensure you ran `source ~/.bashrc`

**STOP: Do not continue until `openclaw --version` shows a version number.**

---

# Phase 3: Get an API Key
*"The credential that lets you access AI models"*

## Understanding API Keys and Costs

**What an API key is:**
- A secret string that identifies you to the AI provider
- Like a password that grants access to AI models
- Tied to your payment method for billing

**Typical costs (pay-per-use):**
| Usage Level | Messages/Day | Monthly Cost |
|-------------|--------------|--------------|
| Light | 5-10 | $3-8 |
| Medium | 20-30 | $8-15 |
| Heavy | 50+ | $15-25 |

## Get an Anthropic API Key (Recommended)

Anthropic's Claude models work excellently with OpenClaw.

1. **Go to:** https://console.anthropic.com

2. **Create account:**
   - Sign up with your email
   - Verify your email address
   - Complete phone verification when prompted

3. **Add payment method:**
   - Navigate to "Billing" or "Settings"
   - Add a credit/debit card
   - Set a spending limit (recommended: start with $10-25)

4. **Create your API key:**
   - Navigate to "API Keys"
   - Click "Create Key"
   - Give it a name like "OpenClaw"
   - **IMPORTANT:** Copy the key immediately - you cannot view it again!
   - The key starts with `sk-ant-`

5. **Save your key securely:**
   ```bash
   # Create a secure location for your key (for your reference only)
   echo "My Anthropic key: sk-ant-xxxxx" >> ~/.api-keys-backup
   chmod 600 ~/.api-keys-backup
   ```

**Alternative: OpenAI API Key**

1. Go to https://platform.openai.com
2. Sign up and verify
3. Add payment method under "Billing"
4. Create API key under "API keys"
5. Key starts with `sk-`

---

# Phase 4: Configure OpenClaw
*"Connecting everything together"*

## Start the Gateway

The Gateway is the background service that handles all AI communication. It must be running before you can use OpenClaw.

```bash
# Check Gateway status
openclaw gateway status
```

**If Gateway is not running:**
```bash
# Start the Gateway
openclaw gateway start
```

**Verify it's running:**
```bash
openclaw gateway status
```

You should see status information indicating the Gateway is active.

## Configure Your API Key

Set your Anthropic API key as an environment variable:

```bash
# Add to your shell configuration for persistence
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.bashrc

# Load the new configuration
source ~/.bashrc
```

**Replace `sk-ant-your-key-here` with your actual API key.**

For OpenAI, use:
```bash
echo 'export OPENAI_API_KEY="sk-your-key-here"' >> ~/.bashrc
source ~/.bashrc
```

## Verify Configuration

```bash
# Check that your key is set
echo $ANTHROPIC_API_KEY
```

Should display your key (starting with `sk-ant-`).

**STOP: Do not continue until Gateway is running and your API key environment variable is set.**

---

# Phase 5: Your First Conversation
*"The payoff moment"*

## Start the Interactive Interface

```bash
openclaw tui
```

**What `tui` means:** "Text User Interface" - an interactive terminal-based chat interface.

**Good first messages to try:**
- "Hello! What can you help me with?"
- "Explain quantum computing in simple terms"
- "Write a haiku about programming"

**To exit:** Press `Ctrl+C` or type `/exit`

## If Your First Chat Fails

**"Gateway not running" or connection errors:**
```bash
openclaw gateway status
openclaw gateway start  # if not running
```

**"Invalid API key" or authentication errors:**
- Double-check your ANTHROPIC_API_KEY is set: `echo $ANTHROPIC_API_KEY`
- Verify the key is correct (no extra spaces, complete string)
- Check that you've added a payment method on console.anthropic.com

**"Rate limit" errors:**
- Wait 60 seconds and try again
- Check your usage on console.anthropic.com

**Slow responses (first time):**
- First request can take 10-30 seconds
- Subsequent requests are typically 2-10 seconds

## Success!

**If you got a coherent response, congratulations!** You now have:
- ✓ A working AI assistant
- ✓ Private conversations on your machine  
- ✓ Control over your costs
- ✓ Foundation for advanced features

---

# Managing OpenClaw

## Gateway Commands

The Gateway is the heart of OpenClaw. Here are the essential commands:

```bash
# Check status
openclaw gateway status

# Start the Gateway
openclaw gateway start

# Stop the Gateway  
openclaw gateway stop

# Restart (useful after configuration changes)
openclaw gateway restart

# Get help
openclaw --help
openclaw gateway --help
```

## Auto-Start Gateway (Optional)

To have the Gateway start automatically when you open Ubuntu:

```bash
# Add to your shell startup
echo 'openclaw gateway start 2>/dev/null &' >> ~/.bashrc
```

## WSL2-Specific Tips

**Accessing Windows files:**
```bash
# Your Windows files are at:
cd /mnt/c/Users/YourWindowsUsername/

# Example: access your Downloads folder
ls /mnt/c/Users/YourName/Downloads/
```

**Memory management:**
WSL2 can use a lot of RAM. If needed, create `C:\Users\YourName\.wslconfig`:
```ini
[wsl2]
memory=4GB
processors=2
```

**Keeping WSL2 running:**
The Gateway stops when all Ubuntu terminals close. Keep one terminal open, or use:
```bash
# From Windows PowerShell, keep WSL running:
wsl -d Ubuntu-24.04 -e bash -c "openclaw gateway start && sleep infinity"
```

---

# What's Next

## Optional Integrations

Now that the core works, you can add:

- **Discord Bot** - Chat with your AI from phone/anywhere
- **Web Interface** - Browser-based UI for easier interaction
- **Calendar Integration** - "What's my schedule today?"
- **File Analysis** - Analyze documents, images, code

## Getting Help

**If something breaks:**
1. Check Gateway status: `openclaw gateway status`
2. Restart Gateway: `openclaw gateway restart`
3. Check help: `openclaw --help`
4. Review logs for error messages

**Useful diagnostic commands:**
```bash
# System info
lsb_release -a
node --version
openclaw --version

# Gateway status
openclaw gateway status

# Environment check
echo $ANTHROPIC_API_KEY | head -c 10  # Shows first 10 chars only (safe)
```

## Updating OpenClaw

```bash
sudo npm update -g openclaw
```

## Uninstalling

```bash
# Stop the Gateway first
openclaw gateway stop

# Remove OpenClaw
sudo npm uninstall -g openclaw

# Remove configuration (optional)
rm -rf ~/.openclaw

# Remove API key from bashrc (optional)
# Manually edit ~/.bashrc and remove the ANTHROPIC_API_KEY line
```

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Start Gateway | `openclaw gateway start` |
| Stop Gateway | `openclaw gateway stop` |
| Gateway Status | `openclaw gateway status` |
| Interactive Chat | `openclaw tui` |
| Get Help | `openclaw --help` |
| Check Version | `openclaw --version` |
| Update OpenClaw | `sudo npm update -g openclaw` |

---

*Last updated: February 19, 2026*  
*Target environment: Ubuntu 24.04 LTS on WSL2*
