# Hermes Local Embeddings Setup Guide

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- **Hermes docs/config assumptions:** 2026-07 baseline
- **Last validated:** 2026-07-01

This guide documents how to configure Hermes to use local embeddings for memory search instead of expensive API calls to OpenAI/Google.

## Problem Statement

Hermes's memory search functionality was disabled due to missing API keys:
- Memory search required OpenAI or Google API keys for embeddings
- This created ongoing costs for memory functionality
- Privacy concern: sending memory content to external APIs

## Solution Overview

Configure Hermes to use local embeddings via HuggingFace models, eliminating:
- API costs for memory search
- External API dependencies
- Privacy concerns with memory content
- Fast, offline memory search functionality

## Prerequisites

- Hermes installed and running
- Ollama installed (we used this initially, but switched to direct HuggingFace)
- Linux (non-WSL) environment (though this works on any Linux system)

## Step 1: Install Local Embedding Model

We initially tried using Ollama but found Hermes's local provider expects GGUF files or HuggingFace URIs directly.

```bash
# This was our initial attempt (works but not directly compatible)
ollama pull mxbai-embed-large
```

## Step 2: Configure Hermes Memory Search

The key is configuring Hermes to use the `local` provider with a HuggingFace model URI:

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
 "fallback": "none"
 }
 }
 }
}
```

Apply this configuration:

```bash
# Method 1: Using Hermes's config API
# Config patch command availability varies by version; edit ~/.hermes/config.yaml directly

# Method 2: Edit config file directly
nano ~/.hermes/config.yaml
# Add the memorySearch section under agents.defaults
```

## Step 3: Handle Cache/Persistence Issues

> **Fix 16.10 (Sol-audit P1):** ÄLÄ koskaan `rm`-osaa muistikannasta "force
> regeneration" -syystä — se POISTAA muistitiedot pysyvästi. Muistitiedosto =
> user data. Jos config ei vaikuta: (1) `hermes doctor` (asennustilanne),
> (2) `hermes gateway restart` (config-lukija), (3) backup ensin (katso
> docs/memory-system/SETUP.md §5) ja VASTA tämän jälkeen harkitse datasiirtoa.

```bash
# Tilanne: muistikonfiguraation muutokset ei vaikuta?
# 1) Diagnoosi (ei kirjoitusta):
hermes doctor | grep -i memory
hermes status | grep Memory

# 2) Jos täytyy siirtää dataa: BACKUP ENSIN, uudelleen rakenteen kanssa
# (ei rm:ää koskaan suoraan)
cp -a ~/.hermes/memory ~/.hermes/memory.bak-$(date +%F)
python3 - <<'EOF'
# sqlite-lukija: backup-API (ei live-copyä, gateway saan olla päällä)
import sqlite3
src = sqlite3.connect("file:$HOME/.hermes/memory/main.sqlite?mode=ro", uri=True) # muuta oma HOME
dst = sqlite3.connect("/tmp/main.sqlite.fresh")
src.backup(dst); dst.close(); src.close()
print("backup OK — vaihda vain VARMISTETTUASI")
EOF
```

## Step 4: Test Memory Search

Create or verify memory files exist:

```bash
# Check existing memory files
ls -la ~/.hermes/workspace/memory/

# Create main memory file if missing
echo "# Test Memory Content

This is a test to verify memory search works with local embeddings." > ~/.hermes/workspace/MEMORY.md
```

Wait for indexing (watch the status):
```bash
# Should show files being indexed
hermes status | grep Memory
# Output: │ Memory │ X files · Y chunks · sources memory · plugin memory-core · vector ready · fts ready │
```

Test the functionality:
```bash
# This should now work without API errors
hermes memory search "test embeddings"
```

## Verification Steps

### Success Indicators

1. **Memory Status Shows Files**:
 ```
 │ Memory │ 7 files · 9 chunks · sources memory · plugin memory-core · vector ready · fts ready │
 ```

2. **Memory Search Works**:
 ```json
 {
 "results": [...],
 "provider": "local",
 "model": "hf:mixedbread-ai/mxbai-embed-large-v1",
 "citations": "auto"
 }
 ```

3. **No API Errors**: No more "No API key found" errors

### Common Issues

1. **"No model file found at /path/to/ollama/model"**
 - Solution: Use HuggingFace URI format `hf:model-name` instead of Ollama paths

2. **Memory search returns empty results**
 - Solution: Ensure memory files exist in `~/.hermes/workspace/MEMORY.md` and `~/.hermes/workspace/memory/`
 - Wait for indexing to complete (check status)

3. **Configuration not applying**
 - Solution (FIX 17.10, Sol-audit: ÄLÄ koskaan rm:ää muistikantaa = data-tuhoo):
   1. `hermes doctor | grep -i memory` (diagnoosi)
   2. `hermes gateway restart` (config-lukija uusinta)
   3. Vain viimeisenä: backup-API:lla kopio (`cp -a` + sqlite backup-API — katso Step 3 yläpuolella), VÄLITTÖMÄN verifioinnin jälkeen harkitse vaihtoa
   4. Katoamisselvitys: `hermes status | grep Memory` (chunking-tila)

## Configuration Details

### Final Working Configuration

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
 "fallback": "none"
 }
 }
 }
}
```

### Alternative Models

You can use other embedding models:
```json
{
 "local": {
 "modelPath": "hf:sentence-transformers/all-MiniLM-L6-v2"
 }
}
```

Or local GGUF files:
```json
{
 "local": {
 "modelPath": "/path/to/local/embedding-model.gguf"
 }
}
```

## Benefits Achieved

- **Cost**: $0 per month for memory search (was potentially $X/month with API usage)
- **Privacy**: All memory content stays local
- **Performance**: Fast searches without network latency
- **Reliability**: Works offline, no API rate limits

## Technical Notes

- **Model Size**: The mxbai-embed-large-v1 model is approximately 669MB
- **First Run**: Model downloads automatically on first use
- **Storage**: Embeddings cached locally in SQLite database
- **Memory Files**: Supports both `MEMORY.md` and `memory/*.md` files
- **Indexing**: Automatic file watching with debounced reindexing

## Troubleshooting

### Check Current Configuration
```bash
grep -nA 12 '"memorySearch"' ~/.hermes/config.yaml
```

### Monitor Memory System
```bash
# Watch for indexing progress
watch 'hermes status | grep Memory'
```

### Test Memory Search
```bash
# Should return results without errors
hermes memory search "your search query"
```

### Reset Memory Database
> **FIX 17.10 (Sol-audit):** tämä poistaa muistit datan pysyvästi — EI tee näin.
> Aito reitti: (1) hermes doctor + gateway restart; (2) jos aito data-rebuild
> tähtäin: BACKUP ENSIN (sqlite backup-API, katso ylempänä), verify (row-count
> ennen/jälkeen), VASTA sitten harkitse.
```bash
# Poistettu vaarallinen ohje — katso diagnoso-ja-backup-putki ylempänä
# (rm ~/.hermes/memory/main.sqlite POISTETTU tästä dokumentista 17.10)
```

## Conclusion

This configuration provides a fully functional, cost-free, privacy-respecting memory search system for Hermes. The local embedding approach eliminates external dependencies while maintaining excellent search quality.

> **v0.21.2 alternative - Honcho memory:** Hermes v0.21.2 also supports Honcho as a memory integration plugin. Honcho provides higher-level memory management (session-aware context, user modeling) on top of embedding-based search. If local embeddings meet your needs, no change is required. If you want richer memory semantics, consider installing the Honcho plugin via `hermes plugins install honcho` and consulting the Hermes docs for configuration.

---

*Created: 2026-02-06*
*Environment: Linux (non-WSL), Hermes 0.21.2*
