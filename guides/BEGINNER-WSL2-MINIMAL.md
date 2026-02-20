# OpenClaw Setup Guide for WSL2/Ubuntu
*From "Never used Linux" to "Working AI Assistant" in 20-30 minutes*

---

## Why WSL2?

If you're on Windows, **WSL2 (Windows Subsystem for Linux) is the best way to run OpenClaw**:

- **Better compatibility** — OpenClaw is designed for Unix-like systems
- **Faster** — Native Linux performance, not emulation
- **Cleaner** — Isolated from your Windows setup, easy to reset if needed
- **Real Linux skills** — Commands you learn work on any Linux server

This guide assumes you're starting fresh with WSL2 on Windows 10/11.

---

## Prerequisites

**You need:**
- Windows 10 (version 2004+) or Windows 11
- Admin access to your computer
- Stable internet (~500MB download)
- Google account (for OAuth — the easy path)
- 20-30 minutes

---

## Step 1: Install WSL2 + Ubuntu

**Open PowerShell as Administrator:**
1. Press `Windows key`, type `powershell`
2. Right-click "Windows PowerShell" → **Run as administrator**
3. Click "Yes" when prompted

**Run this command:**
```powershell
wsl --install -d Ubuntu-24.04
```

**What happens:**
- Downloads and installs WSL2 (~1-2 minutes)
- Downloads Ubuntu 24.04 (~500MB, 3-5 minutes)
- **Restart required** — save your work first

**After restart:**
- Ubuntu terminal opens automatically
- Create a username (lowercase, no spaces) and password
- **Remember this password** — you'll need it for `sudo` commands

**If Ubuntu doesn't auto-open:** Search for "Ubuntu" in Start menu.

---

## Step 2: Install Node.js

**In your Ubuntu terminal, run these commands one at a time:**

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
```
*(Enter your password when prompted — it won't show as you type)*

```bash
sudo apt-get install -y nodejs
```

**Verify it worked:**
```bash
node --version
```

**Expected output:** `v20.x.x` or `v22.x.x` (any v18+ is fine)

**If it fails:** Run `sudo apt update && sudo apt upgrade -y` first, then try again.

---

## Step 3: Install OpenClaw

```bash
npm install -g openclaw
```

**Takes 2-5 minutes.** You'll see packages downloading.

**Verify:**
```bash
openclaw --version
```

**Expected output:** `2026.x.x`

---

## Step 4: Connect to AI (OAuth — Easy Path)

```bash
openclaw configure
```

**Follow the prompts:**
1. Choose **Anthropic Claude** (recommended)
2. Choose **OAuth Login**
3. Browser opens → Sign in with Google
4. Click "Allow OpenClaw to access Claude"
5. Return to terminal → Should show "✓ Authentication successful"

**If browser doesn't open:** Copy the URL from terminal, paste into your Windows browser manually.

**OAuth is free to start** — you get generous daily limits before any charges.

---

## Step 5: Verify & Test

**Run the health check:**
```bash
openclaw doctor
```

**Expected:** All checkmarks (✓)

**Test a conversation:**
```bash
openclaw chat
```

Try: "Hello! What can you help me with?"

**To exit:** Type `exit` or press `Ctrl+C`

---

## You're Done! 🎉

You now have:
- ✓ Linux environment via WSL2
- ✓ Working AI assistant
- ✓ Private conversations on your computer
- ✓ Foundation for Discord bots, email integration, and more

---

## Quick Reference

| Command | What it does |
|---------|-------------|
| `openclaw chat` | Start conversation |
| `openclaw doctor` | Check if everything works |
| `openclaw configure` | Change AI provider/settings |
| `openclaw --help` | See all commands |

**Access Ubuntu anytime:** Open "Ubuntu" from Start menu or type `wsl` in any terminal.

---

## Troubleshooting

### WSL2 Issues

**"WSL2 requires a kernel update"**
```powershell
wsl --update
```
Then restart and try again.

**"Virtualization not enabled"**
1. Restart computer → Enter BIOS (usually F2, F10, or Del during boot)
2. Find "Virtualization Technology" or "VT-x" → Enable it
3. Save and restart

**Ubuntu hangs on install**
```powershell
wsl --shutdown
wsl --install -d Ubuntu-24.04
```

### Node.js Issues

**"Permission denied" during npm install**
```bash
sudo npm install -g openclaw
```

**"Command not found" after install**
Close and reopen Ubuntu terminal, then try again.

### OpenClaw Issues

**"Invalid API key" or "Connection failed"**
```bash
openclaw configure
```
Redo the OAuth flow — make sure to complete the browser authorization.

**OAuth browser doesn't open**
Copy the displayed URL → Paste into Windows browser → Complete auth → Return to terminal.

**"Rate limit exceeded"**
Wait 1 minute and try again. Free tiers have per-minute limits.

### Still Stuck?

1. Run `openclaw doctor` and read the specific error
2. Check the OpenClaw Discord community
3. Search GitHub Issues for your error message

---

## What's Next?

Once the basics work, explore:
- **Discord Bot** — Chat with your AI from anywhere (10 min setup)
- **Web Interface** — Pretty UI instead of terminal
- **Email/Calendar** — "What's my schedule today?"

---

*Guide optimized for Ubuntu 24.04 LTS on WSL2 • February 2026*
