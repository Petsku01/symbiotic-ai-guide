# Signal Messenger Setup for Hermes

Connect Signal to Hermes for bidirectional messaging via signal-cli daemon.

## Prerequisites

- A Signal account on a phone (for QR linking)
- Hermes gateway running (`hermes gateway status`)
- WSL2 or Linux with systemd support

## Architecture

```
Phone (Signal app) <-> Signal servers <-> signal-cli daemon (:8080) <-> Hermes gateway
```

signal-cli runs as a local HTTP daemon (JSON-RPC for outbound, SSE for inbound). Hermes gateway connects to it via environment variables.

---

## Step 1: Install signal-cli (JRE version + JDK 25)

signal-cli 0.14.4+ requires Java 25 (class file version 69). Use the JRE distribution so you can patch the JAR if needed (see Troubleshooting).

```bash
# Install JDK 25 (Temurin)
cd /tmp
curl -sL -o jdk25.tar.gz "https://github.com/adoptium/temurin-binaries/releases/download/jdk-25.0.3%2B9/OpenJDK25U-jdk_x64_linux_hotspot_25.0.3_9.tar.gz"
tar xzf jdk25.tar.gz
mkdir -p ~/.local/share
cp -r jdk-25.0.3+9 ~/.local/share/jdk-25

# Download signal-cli JRE version
LATEST_VER=$(curl -sL https://api.github.com/repos/AsamK/signal-cli/releases/latest | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])")
curl -sL "https://github.com/AsamK/signal-cli/releases/download/${LATEST_VER}/signal-cli-${LATEST_VER#v}.tar.gz" -o signal-cli-jre.tar.gz
tar xzf signal-cli-jre.tar.gz
cp -r signal-cli-${LATEST_VER#v} ~/.local/share/signal-cli-jre

# Verify
export JAVA_HOME=~/.local/share/jdk-25 PATH=$JAVA_HOME/bin:$PATH
~/.local/share/signal-cli-jre/bin/signal-cli --version
```

**Pitfall:** The `Linux-native.tar.gz` is a GraalVM binary (~340MB) that cannot be JAR-patched. Use the plain `.tar.gz` (JRE distribution) instead. If you already have the native binary, replace it with a wrapper script:

```bash
# Backup native binary
mv ~/.local/bin/signal-cli ~/.local/bin/signal-cli-native.bak

# Create wrapper
cat > ~/.local/bin/signal-cli << 'WRAPPER'
#!/bin/bash
export JAVA_HOME=/home/$USER/.local/share/jdk-25
export PATH=$JAVA_HOME/bin:$PATH
exec /home/$USER/.local/share/signal-cli-jre/bin/signal-cli "$@"
WRAPPER
chmod +x ~/.local/bin/signal-cli

# Verify
signal-cli --version
```

---

## Step 2: Link your phone (QR code)

```bash
# Start link process in background
signal-cli link -n "Hermes-Agent" > /tmp/signal-link-out.txt 2>&1 &
sleep 5
LINK_URL=$(head -1 /tmp/signal-link-out.txt)
echo "Link URL: $LINK_URL"

# Generate QR code as PNG
pip install qrcode pillow
python3 -c "
import qrcode
qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_L)
qr.add_data('$LINK_URL')
img = qr.make_image(fill_color='black', back_color='white')
img.save('/tmp/signal-qr.png')
print('QR saved to /tmp/signal-qr.png')
"
```

On your phone: **Settings -> Linked devices -> Add device -> scan the QR code**

You can open the PNG on your desktop or transfer it to view and scan.

**Pitfall:** The link URL expires in ~60 seconds. If linking fails, kill the process and regenerate:
```bash
pkill -f signal-cli
signal-cli link -n "Hermes-Agent" > /tmp/signal-link-out.txt 2>&1 &
```

Verify linking:
```bash
signal-cli -u +<YOUR_PHONE> listDevices
```

---

## Step 3: Configure Hermes .env

Add to `~/.hermes/.env`:

```
SIGNAL_HTTP_URL=http://127.0.0.1:8080
SIGNAL_ACCOUNT=+<YOUR_PHONE_NUMBER>
SIGNAL_HOME_CHANNEL=+<YOUR_PHONE_NUMBER>
```

**Important:** Replace `<YOUR_PHONE_NUMBER>` with your actual phone number in international format (e.g., +358...).

**Pitfall:** If `security.redact_secrets: true` is set in config.yaml, phone numbers in .env and service files may appear as `+358****3308`. If Signal fails to connect, verify the real number is in .env. Temporarily set `redact_secrets: false`, write the number, verify with `cat ~/.hermes/.env | grep SIGNAL`, then re-enable redaction if desired.

---

## Step 4: Create systemd service for signal-cli daemon

Create `~/.config/systemd/user/signal-cli.service`:

```ini
[Unit]
Description=Signal CLI Daemon for Hermes Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/home/$USER/.local/share/signal-cli-jre/bin/signal-cli --config /home/$USER/.local/share/signal-cli -u +<PHONE> daemon --http 127.0.0.1:8080
Restart=on-failure
RestartSec=10
Environment=JAVA_HOME=/home/$USER/.local/share/jdk-25
Environment=PATH=/home/$USER/.local/share/jdk-25/bin:/usr/local/bin:/usr/bin:/bin

[Install]
WantedBy=default.target
```

Replace `$USER` and `<PHONE>` with your actual username and phone number.

```bash
systemctl --user daemon-reload
systemctl --user enable --now signal-cli.service
systemctl --user status signal-cli.service  # verify "active (running)"
```

---

## Step 5: Start Hermes gateway

```bash
hermes gateway restart
# or: ~/.hermes/gateway-restart.sh
```

Verify in logs:
```bash
grep signal ~/.hermes/logs/gateway.log | tail -5
# Should show: signal connected
```

---

## Step 6: Test

Send a message to your Signal account from another Signal user. Hermes should receive and respond.

You can also test outbound:
```bash
# Send via JSON-RPC directly
curl -s -X POST http://127.0.0.1:8080/api/v1/rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"send","params":{"account":"+PHONE","message":"test","recipient":"+PHONE"},"id":1}'
```

---

## Media Limitations

| Type | Format | Supported |
|------|--------|-----------|
| Images | JPG, PNG, WEBP | Yes |
| Audio | OGG, MP3 | Yes (auto-transcribed, quality varies) |
| Video | MP4, MOV, etc. | No - dropped silently |

**Video workaround:** Extract a frame or audio track with ffmpeg, or ask for a screenshot.

---

## Troubleshooting

### "cannot reach signal-cli at http://127.0.0.1:8080"

- **Daemon not running:** `systemctl --user status signal-cli.service`
- **Port not listening:** `ss -tlnp | grep 8080`
- **Health check:** `curl -s http://127.0.0.1:8080/api/v1/check` should return HTTP 200

### Signal adapter not loaded

- Missing .env vars: `grep SIGNAL ~/.hermes/.env`
- Gateway reads env vars at startup - restart required after .env changes
- Both `SIGNAL_HTTP_URL` and `SIGNAL_ACCOUNT` must be set

### getServerGuid NullPointerException

**Known bug** in signal-cli all versions up to and including 0.14.5. Signal's server stopped sending the `serverGuid` field, and signal-cli crashes on null.

Symptom in logs:
```
journalctl --user -u signal-cli.service --since "1 hour ago" | grep NullPointerException
```

**Fix:** Patch the JAR to handle null serverGuid. See the Hermes Agent skill reference `references/signal-jar-patching-npe-fix.md` for the full procedure. Re-patch is required after every signal-cli upgrade until upstream fixes it.

**WARNING:** The nil-UUID patch (`"00000000-0000-0000-0000-000000000000"`) from GitHub issue #2059 is DANGEROUS. It causes silent data loss via replay dedup collision. Do NOT use it. The correct fix is to make `serverGuid` nullable and skip replay checking when null.

### SSE "All connection attempts failed"

- Normal during gateway restart - daemon takes a moment to be ready
- Gateway auto-reconnects with exponential backoff (2s -> 4s -> 8s -> 16s -> 60s max)
- Check for eventual "Signal SSE: connected" in logs

### "Failed to retrieve profile" warnings

- Normal - contact profile fetch failures
- Non-critical, can ignore

---

## Upgrading signal-cli

When Signal messages stop arriving, check if signal-cli needs updating:

```bash
# Current version
signal-cli --version

# Latest release
curl -sL https://api.github.com/repos/AsamK/signal-cli/releases/latest | grep '"tag_name"'
```

Upgrade procedure:

```bash
# 1. Download new JRE version
LATEST_VER=$(curl -sL https://api.github.com/repos/AsamK/signal-cli/releases/latest | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])")
curl -sL "https://github.com/AsamK/signal-cli/releases/download/${LATEST_VER}/signal-cli-${LATEST_VER#v}.tar.gz" -o /tmp/signal-cli-new.tar.gz

# 2. Stop daemon before replacing
systemctl --user stop signal-cli.service

# 3. Backup and replace
cp -r ~/.local/share/signal-cli-jre ~/.local/share/signal-cli-jre.bak
cd /tmp && tar xzf signal-cli-new.tar.gz
rm -rf ~/.local/share/signal-cli-jre
cp -r signal-cli-${LATEST_VER#v} ~/.local/share/signal-cli-jre

# 4. Re-apply NPE JAR patch (required on every upgrade!)
# See references/signal-jar-patching-npe-fix.md

# 5. Restart
systemctl --user start signal-cli.service
systemctl --user restart hermes-gateway.service

# 6. Verify
journalctl --user -u signal-cli.service --since "1 min ago" --no-pager
```

**Pitfall:** You cannot replace files while the daemon is running. Always `systemctl --user stop signal-cli.service` first.

**Pitfall:** After upgrading, re-apply the NPE JAR patch. The patch is lost on every upgrade until upstream fixes it.

---

## Switching from Discord to Signal

```bash
# Once Signal is confirmed working:
hermes config edit    # Remove or comment out Discord section
hermes gateway restart
```

Both platforms can run simultaneously if you prefer a gradual transition.

---

## References

- [signal-cli GitHub](https://github.com/AsamK/signal-cli)
- [Hermes Agent Signal reference](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)
- Hermes Agent skill: `references/signal-setup.md` and `references/signal-gateway-setup.md`