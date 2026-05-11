# Hermes Setup Guide for WSL2/Ubuntu
*From "Never used Linux" to "Working AI Assistant" in 20-30 minutes*

---

## Why WSL2?

If you're on Windows, **WSL2 (Windows Subsystem for Linux) is the best way to run Hermes**:

- **Better compatibility** — Hermes is designed for Unix-like systems  
- **Faster** — Native Linux performance, not emulation
- **Cleaner** — Isolated from Windows, easy to reset if needed
- **Real Linux skills** — Commands work on any Linux server/cloud

This guide targets **Ubuntu 24.04 LTS on WSL2** — the proven working environment.

---

## How Hermes Works

Understanding the architecture helps avoid confusion:

```
┌─────────────────────────────────────────────────────────────┐
│  Your Computer (Ubuntu 24.04 WSL2)                          │
│                                                             │
│   ┌─────────────┐         ┌──────────────────────────────┐ │
│   │ hermes    │ ──────► │ Hermes Gateway             │ │
│   │ tui         │         │ (background daemon)          │ │
│   │ (chat CLI)  │         │                              │ │
│   └─────────────┘         │ • Manages AI connections     │ │
│                           │ • Handles authentication     │ │
│         ▲                 │ • Routes requests to APIs    │ │
│         │                 │ • Must be running first      │ │
│   You type here           └──────────────────────────────┘ │
│                                      │                      │
└──────────────────────────────────────│──────────────────────┘
                                       │
                                       ▼ HTTPS
                              ┌──────────────────┐
                              │ AI Provider API  │
                              │ (Ollama Cloud, etc) │
                              └──────────────────┘
```

**Key concept:** Gateway daemon runs in background, CLI tools (`hermes tui`) talk to it.

---

## Prerequisites

**You need:**
- Windows 10 (version 2004+) or Windows 11
- Admin access to your computer  
- Stable internet (~500MB download)
- Credit card for API provider (or OAuth account)
- 20-30 minutes focused time

**Realistic costs:** Light usage ~$3-8/month, Heavy usage ~$15-25/month (pay-per-use)

---

## Step 1: Install WSL2 + Ubuntu 24.04

**Open PowerShell as Administrator:**
1. Press `Windows key`, type `powershell`
2. Right-click "Windows PowerShell" → **Run as administrator**
3. Click "Yes" when prompted

**Install command:**
```powershell
wsl --install -d Ubuntu-24.04
```

**What happens:**
- Downloads WSL2 and Ubuntu 24.04 (~500MB, 3-5 minutes)
- **Restart required** — save your work first
- After restart: Ubuntu opens, create username/password
- **Remember this password** — needed for `sudo` commands

**If Ubuntu doesn't auto-open:** Search "Ubuntu" in Start menu.

**Verify you're in Ubuntu 24.04:**
```bash
lsb_release -a
```
Should show: `Ubuntu 24.04 LTS`

---

## Step 2: Install Node.js 

**In Ubuntu terminal, run these commands:**

```bash
# Update package lists
sudo apt update

# Add NodeSource repository for latest Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs
```

**Verify installation:**
```bash
node --version
```
**Expected:** `v20.x.x` or `v22.x.x` (any v18+ works)

```bash
npm --version  
```
**Expected:** `10.x.x` or similar

**STOP:** Don't continue until both show version numbers.

---

## Step 3: Install Hermes

```bash
npm install -g hermes
```

**Takes 2-5 minutes.** You'll see packages downloading.

**If permission errors:**
```bash
sudo npm install -g hermes
```

**Verify installation:**
```bash
hermes --version
```
**Expected:** `2026.x.x`

**STOP:** Don't continue until version shows.

---

## Step 4: Get API Access

**Recommended: Ollama Cloud models (GLM-5.1, Kimi K2.6, DeepSeek V4 Pro)**

### Option A: OAuth (Recommended - Easy Setup)

```bash
hermes configure
```

**Follow the prompts:**
1. Choose **Ollama Cloud** (recommended)
2. Choose **OAuth Login**
3. Browser opens → Sign in with Google
4. Follow the authentication prompts for Ollama Cloud
5. Return to terminal → Should show "✓ Authentication successful"

**If browser doesn't open:** Copy the URL from terminal, paste into your Windows browser manually.

**OAuth is free to start** — you get generous daily limits before any charges.

### Option B: API Key (Fallback - if OAuth doesn't work)

**Only if OAuth fails, get Ollama Cloud API key:**
1. Go to https://ollama.com/cloud
2. Sign up, verify email, add phone number  
3. Add payment method (credit/debit card)
4. Navigate to "API Keys" → "Create Key"
5. Name it "Hermes", copy the key (starts with `sk-ant-`)

**Set your API key:**
```bash
# Add to shell configuration  
echo 'export ANTHROPIC_API_KEY="sk-ant-your-actual-key-here"' >> ~/.bashrc

# Reload configuration
source ~/.bashrc

# Verify it's set
echo $ANTHROPIC_API_KEY
```
Should show your key starting with `sk-ant-`.

**STOP:** Don't continue until authentication is configured (either API key OR OAuth working).

---

## Step 5: Start Hermes

**Start the Gateway (required first):**
```bash
hermes gateway start
```

**Verify Gateway is running:**
```bash
hermes gateway status
```
Should show status information indicating Gateway is active.

**Start your first conversation:**
```bash
hermes tui
```

**Good test messages:**
- "Hello! What can you help me with?"
- "Explain quantum computing simply"  
- "Write a haiku about Linux"

**To exit:** Press `Ctrl+C` or type `/exit`

---

## Success! 🎉

**If you got a coherent response, you now have:**
- ✓ Ubuntu Linux environment (WSL2)
- ✓ Working AI assistant  
- ✓ Private conversations on your computer
- ✓ Foundation for Discord bots, integrations, etc.

---

## Essential Commands

| Task | Command |
|------|---------|
| Start Gateway | `hermes gateway start` |
| Stop Gateway | `hermes gateway stop` |  
| Gateway Status | `hermes gateway status` |
| Interactive Chat | `hermes tui` |
| Get Help | `hermes --help` |
| Check Version | `hermes --version` |

**Gateway management:** Always ensure Gateway is running before using `hermes tui`.

---

## WSL2 Tips

**Auto-start Gateway (optional):**
```bash
# Add to shell startup
echo 'hermes gateway start 2>/dev/null &' >> ~/.bashrc
```

**Access Windows files:**
```bash
# Your Windows files are at:
cd /mnt/c/Users/YourWindowsUsername/

# Example: Downloads folder
ls /mnt/c/Users/YourName/Downloads/
```

**Keep WSL2 running:**
Gateway stops when all Ubuntu terminals close. Keep one terminal open, or from Windows PowerShell:
```powershell
wsl -d Ubuntu-24.04 -e bash -c "hermes gateway start && sleep infinity"
```

**Memory management (if needed):**
Create `C:\Users\YourName\.wslconfig`:
```ini
[wsl2]
memory=4GB
processors=2
```

---

## Quick Troubleshooting

**"Gateway not running" errors:**
```bash
hermes gateway status
hermes gateway start  # if stopped
```

**"Invalid API key" errors:**
- Check: `echo $ANTHROPIC_API_KEY` shows your key
- Verify payment method on ollama.com/cloud
- Regenerate key if needed

**"Permission denied" during npm install:**
```bash
sudo npm install -g hermes
```

**Commands not found after install:**
Close and reopen Ubuntu terminal.

**WSL2 won't start:**
```powershell
wsl --update
wsl --shutdown  
wsl --install -d Ubuntu-24.04
```

---

## What's Next?

**Optional integrations:**
- **Discord Bot** — Chat from anywhere
- **Web Interface** — Browser UI instead of terminal
- **Calendar/Email** — "What's my schedule?"
- **File Analysis** — Analyze documents, code

**Update Hermes:**
```bash
sudo npm update -g hermes
```

**More help:**
- Full docs: https://docs.hermes.ai
- Community: https://discord.gg/hermes  
- Issues: https://github.com/hermes/hermes

---

*Final version combining structure + technical accuracy*  
*Target: Ubuntu 24.04 LTS on WSL2 • February 2026*