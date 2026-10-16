# Hermes Setup Guide — Fedora Linux (native)

*Target environment: Fedora 44 (native Linux — no WSL, no virtualization layer)*

## Prerequisites

- Fedora Linux (44+, or any recent release)
- Python 3.11+
- 4 GB+ free disk space
- Terminal access with sudo rights

## Verify your system first

```bash
cat /etc/os-release | head -2     # Fedora Linux 44 (workstation edition or similar)
python3 --version                 # 3.11.x or newer
git --version                     # any recent version
```

**STOP:** All three commands must succeed before continuing.

## Step 1: Install system dependencies

```bash
sudo dnf install -y git python3.11 python3.11-venv python3-pip
```

## Step 2: Install Hermes

> **Note:** Hermes installs from PyPI as `hermes-agent` — NOT from npm
> (the npm `hermes` package is an unrelated project).

```bash
# Isolated venv (recommended)
python3 -m venv ~/.hermes-venv
source ~/.hermes-venv/bin/activate
pip install hermes-agent
```

**Takes 2-5 minutes** depending on your internet connection.

**Verify installation:**
```bash
hermes --version
```

## Step 3: Connect to AI (OAuth — Easy Path)

```bash
hermes login
```

Follow the browser prompt to authenticate. This sets up the default model
provider (Nous Research free tier) — no manual API keys needed.

**Alternative (bring your own keys):** set `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`,
or similar in `~/.hermes/.env` — see [HERMES-CONFIGURATION.md](HERMES-CONFIGURATION.md).

## Step 4: Verify the gateway works

```bash
hermes gateway status
hermes doctor | head -20
```

**Expected:** gateway `active` (or starts on first message), doctor reports
no critical issues.

## Step 5: Choose your next path

- **Memory setup (the interesting part):** [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md)
- **Full memory architecture (3-layer, operator-plugin, offsite backup):**
  [docs/memory-system/REPLICATION-README.md](docs/memory-system/REPLICATION-README.md)
- **Configuration depth:** [HERMES-CONFIGURATION.md](HERMES-CONFIGURATION.md)
- **Signal messaging:** [docs/messaging/SIGNAL-SETUP.md](docs/messaging/SIGNAL-SETUP.md)

## Fedora-specific notes

- **SELinux:** default enforcing mode works; hermes files under `~/.hermes/`
  carry user context (no policy change needed)
- **systemd user units:** gateway runs as a user service —
  `systemctl --user status hermes-gateway.service`
- **Firewall:** gateway is localhost-bound by default; nothing to open
- **dnf updates** don't interfere with the venv — Hermes updates via
  `pip install -U hermes-agent` inside the venv

## Common Fedora issues

**`python3.11` not found (older Fedora):**
```bash
sudo dnf install -y python3.11 python3.11-venv   # available on all supported Fedoras
```

**pip refuses to install system-wide (PEP 668):**
Use the venv path above — that is the intended way. Do not use `--break-system-packages`.

**Gateway won't start:**
```bash
journalctl --user -u hermes-gateway.service -n 30
# typically a credential or config typo — hermes doctor narrows it down
```

## Cleanup / uninstall

```bash
deactivate                       # exit venv
rm -rf ~/.hermes-venv            # removes only the venv
rm -rf ~/.hermes                 # removes ALL hermes state — memory included
```