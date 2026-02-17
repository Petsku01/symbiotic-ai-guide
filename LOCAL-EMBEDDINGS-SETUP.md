# OpenClaw Local Embeddings Setup Guide

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- **OpenClaw docs/config assumptions:** 2026-02 baseline
- **Last validated:** 2026-02-17

This guide documents how to configure OpenClaw to use local embeddings for memory search instead of expensive API calls to OpenAI/Google.

## Problem Statement

OpenClaw's memory search functionality was disabled due to missing API keys:
- Memory search required OpenAI or Google API keys for embeddings
- This created ongoing costs for memory functionality
- Privacy concern: sending memory content to external APIs

## Solution Overview

Configure OpenClaw to use local embeddings via HuggingFace models, eliminating:
- ❌ API costs for memory search
- ❌ External API dependencies 
- ❌ Privacy concerns with memory content
- ✅ Fast, offline memory search functionality

## Prerequisites

- OpenClaw installed and running
- Ollama installed (we used this initially, but switched to direct HuggingFace)
- WSL2 environment (though this works on any Linux system)

## Step 1: Install Local Embedding Model

We initially tried using Ollama but found OpenClaw's local provider expects GGUF files or HuggingFace URIs directly.

```bash
# This was our initial attempt (works but not directly compatible)
ollama pull mxbai-embed-large
```

## Step 2: Configure OpenClaw Memory Search

The key is configuring OpenClaw to use the `local` provider with a HuggingFace model URI:

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
# Method 1: Using OpenClaw's config API
# Config patch command availability varies by version; edit ~/.openclaw/openclaw.json directly

# Method 2: Edit config file directly
nano ~/.openclaw/openclaw.json
# Add the memorySearch section under agents.defaults
```

## Step 3: Handle Cache/Persistence Issues

If you encounter caching issues where the old configuration persists:

```bash
# Remove the old memory database to force regeneration
rm ~/.openclaw/memory/main.sqlite

# Check that the configuration applied
openclaw status | grep Memory
```

## Step 4: Test Memory Search

Create or verify memory files exist:

```bash
# Check existing memory files
ls -la ~/.openclaw/workspace/memory/

# Create main memory file if missing
echo "# Test Memory Content

This is a test to verify memory search works with local embeddings." > ~/.openclaw/workspace/MEMORY.md
```

Wait for indexing (watch the status):
```bash
# Should show files being indexed
openclaw status | grep Memory
# Output: │ Memory │ X files · Y chunks · sources memory · plugin memory-core · vector ready · fts ready │
```

Test the functionality:
```bash
# This should now work without API errors
openclaw memory search "test embeddings"
```

## Verification Steps

### ✅ Success Indicators

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

### ❌ Common Issues

1. **"No model file found at /path/to/ollama/model"**
   - Solution: Use HuggingFace URI format `hf:model-name` instead of Ollama paths

2. **Memory search returns empty results**
   - Solution: Ensure memory files exist in `~/.openclaw/workspace/MEMORY.md` and `~/.openclaw/workspace/memory/`
   - Wait for indexing to complete (check status)

3. **Configuration not applying**
   - Solution: Remove old memory database: `rm ~/.openclaw/memory/main.sqlite`
   - Wait for restart/reload to complete

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
grep -nA 12 '"memorySearch"' ~/.openclaw/openclaw.json
```

### Monitor Memory System
```bash
# Watch for indexing progress
watch 'openclaw status | grep Memory'
```

### Test Memory Search
```bash
# Should return results without errors
openclaw memory search "your search query"
```

### Reset Memory Database
```bash
# If experiencing persistent issues
rm ~/.openclaw/memory/main.sqlite
# Wait for automatic reindexing
```

## Conclusion

This configuration provides a fully functional, cost-free, privacy-respecting memory search system for OpenClaw. The local embedding approach eliminates external dependencies while maintaining excellent search quality.

---

*Created: 2026-02-06*  
*Environment: WSL2, OpenClaw 2026.2.3-1*