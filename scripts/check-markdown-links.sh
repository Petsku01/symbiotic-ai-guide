#!/usr/bin/env bash
# Check local relative markdown links in repository markdown files.

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT_DIR"

python3 - <<'PY'
import pathlib
import re
import sys

root = pathlib.Path('.').resolve()
pattern = re.compile(r'\[[^\]]+\]\(([^)]+)\)')

broken = []
for md in root.rglob('*.md'):
    if '.git' in md.parts:
        continue
    text = md.read_text(encoding='utf-8', errors='ignore')
    for m in pattern.finditer(text):
        target = m.group(1).strip()
        if not target:
            continue
        # Ignore external, anchor-only, and email links.
        if target.startswith(('http://', 'https://', 'mailto:', '#')):
            continue
        # Strip wrapper and anchor/query fragments.
        if target.startswith('<') and target.endswith('>'):
            target = target[1:-1]
        target = target.split('#', 1)[0].split('?', 1)[0].strip()
        if not target:
            continue

        resolved = (root / target.lstrip('/')) if target.startswith('/') else (md.parent / target)
        if not resolved.exists():
            broken.append((md.relative_to(root), m.group(1)))

if broken:
    print('ERROR: Broken markdown links found:')
    for src, dst in broken:
        print(f'  - {src}: {dst}')
    sys.exit(1)

print('OK: Markdown relative links OK')
PY
