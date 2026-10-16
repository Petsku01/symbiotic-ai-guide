# Hermes Setup Guide — Fedora Linux (comprehensive)
*From "Never heard of this" to "Working AI Assistant"*

---

## What Is Hermes?

**Hermes is an open-source AI assistant that runs on your computer.** Unlike ChatGPT or Siri, your conversations stay private and you can customize how it works.

Think of it as your personal AI that:
- Runs locally (your data stays on your machine)
- Works with multiple AI providers (Ollama Cloud, OpenAI, Google, local models)
- Connects to Discord, Signal, email, calendar, and other services
- Costs only what you use (no monthly subscription)

### How Hermes Works (Architecture)

Hermes has two main parts:

```
┌─────────────────────────────────────────────────────────────┐
│ Your Fedora Linux Machine                                   │
│                                                             │
│  ┌─────────────┐       ┌──────────────────────────────┐    │
│  │   hermes    │ ────► │       Hermes Gateway         │    │
│  │   (CLI/TUI) │       │     (background service)     │    │
│  └─────────────┘       └──────────────────────────────┘    │
│                             • Manages AI connections        │
│                             • Handles authentication        │
│         You type here       • Routes requests to models     │
│                                      │                      │
└──────────────────────────────────────│──────────────────────┘
                                       ▼
                       ┌──────────────────┐
                       │  AI Provider API │
                       │ (Ollama Cloud... │
                       └──────────────────┘
```

- **Gateway**: A daemon (background service) that must be running for Hermes to work
- **CLI tools**: Commands like `hermes tui` that you use to interact with the AI

**Realistic time:** 20-40 minutes
**Realistic cost:** Light usage ~$3-8/month, heavy usage ~$15-25/month (pay-per-use)

---

## Before You Start - Prerequisites Check

**You will need:**
- [ ] Fedora Linux (or any recent Fedora/RHEL-family install) — this guide targets native Linux, no WSL/virtualization
- [ ] Stable internet connection (~300 MB download)
- [ ] Credit/debit card (for API provider signup — skip if using Nous free tier)
- [ ] 20-40 minutes of focused time

**Verify the system first:**

```bash
cat /etc/os-release | head -2    # Fedora Linux 4N
python3 --version                # 3.11.x or newer
git --version
```

**STOP:** All three must work before continuing.

---

# Phase 1: Prepare the System

## Install base dependencies

```bash
sudo dnf install -y git python3.11 python3.11-venv python3-pip
```

**Verify:**
```bash
git --version
python3.11 --version
```
**Expected output:** git 2.x, Python 3.11.x

---

# Phase 2: Installing Hermes

*"Getting the actual AI assistant software"*

## Install Hermes

> **Note:** asennus = PyPI-paketti `hermes-agent` (EI npm — npm `hermes` on eri projekti).
> Isolated venv = helpoin ja turvallisin:

```bash
python3 -m venv ~/.hermes-venv
source ~/.hermes-venv/bin/activate
pip install hermes-agent
```

**What you'll see:**
- pip download lines + progress
- 1-3 minutes depending on your connection

## Verify Hermes Installed

```bash
hermes --version
```
**Expected:** `0.19.x` (PyPI; git-install = checkout-versio)

---

# Phase 3: Connect to AI (OAuth — Easy Path)

```bash
hermes login
```

Browser opens — authenticate with your Nous account. Free tier is OK to start.

**Alternative:** bring your own provider keys — `~/.hermes/.env`:
```bash
echo "OPENAI_API_KEY=sk-..." >> ~/.hermes/.env
```

**If "Invalid API key" errors:**
- Re-run `hermes auth add`
- Check provider billing (ollama.com/cloud etc.)

---

# Phase 4: Start the Gateway

```bash
hermes gateway start
```

Or as a systemd user service (survives reboots):
```bash
systemctl --user enable --now hermes-gateway.service
```

**Verify:**
```bash
hermes gateway status
systemctl --user status hermes-gateway.service
```

---

# Phase 5: First Conversation

```bash
hermes chat
```

Type something. Your agent answers — that is the whole loop.

---

# Phase 6: Add Messaging (optional)

Signal (most private), Discord, Telegram — one adapter each:
- Signal: [docs/messaging/SIGNAL-SETUP.md](../docs/messaging/SIGNAL-SETUP.md)

---

# Fedora-Specific Tips

**SELinux:** default enforcing mode works with user-level services; no policy edits needed.

**systemd user services:** enable lingering so the gateway starts at boot without login:
```bash
loginctl enable-linger $USER
```

**Firewall:** gateway binds localhost by default — nothing to open.

**RAM management (native Linux, no WSL):** no `.wslconfig` needed — the OS manages
memory directly. Check with `free -h`.

**Keeping the gateway running:** the systemd service survives terminal closes:
```bash
systemctl --user status hermes-gateway.service   # active = still running
```

**Updates:** two independent layers:
- OS: `sudo dnf upgrade` (does not touch Hermes)
- Hermes: `pip install -U hermes-agent` inside the venv

---

# Troubleshooting Quick Reference

| Symptom | Fix |
|---|---|
| `hermes: command not found` | venv ei aktiivinen: `source ~/.hermes-venv/bin/activate` |
| Gateway ei käynnisty | `journalctl --user -u hermes-gateway.service -n 30` + `hermes doctor` |
| pip kieltää systeemiasennuksen (PEP 668) | Käytä venv-polkua — se on tarkoitettu tapa |
| SELinux-denial lokissa | `ausearch -m avc -ts recent` — yleensä config-polun konteksti; ei kuulu normaaliin asennukseen |
| Signal ei yhdistä | katso [SIGNAL-SETUP.md troubleshooting](../docs/messaging/SIGNAL-SETUP.md) |

---

# What's Next

- **Memory (the real power):** [LOCAL-EMBEDDINGS-SETUP.md](../LOCAL-EMBEDDINGS-SETUP.md) → full 3-layer system: [docs/memory-system/REPLICATION-README.md](../docs/memory-system/REPLICATION-README.md)
- **Configuration depth:** [HERMES-CONFIGURATION.md](../HERMES-CONFIGURATION.md)
- **Automation (cron jobs):** [examples/cron-manifest/README.md](../examples/cron-manifest/README.md)

---

*Target environment: Fedora Linux (native). Tested on Fedora 44, 2026-10.*