#!/bin/bash
# Test memory search quality with sample queries
# Helps verify embeddings are working properly

set -euo pipefail

echo "=== Memory Search Quality Test ==="
echo ""

if ! command -v hermes &> /dev/null; then
  echo "ERROR: hermes command not found"
  exit 1
fi

# Test queries - adjust these for your content
QUERIES=(
  "security hardening"
  "identity configuration"
  "memory system setup"
)

echo "Running test queries..."
echo ""

for query in "${QUERIES[@]}"; do
  echo "Query: \"$query\""

  # Run search and capture results
  RESULT=$(hermes memory search "$query" 2>&1 || true)

  if echo "$RESULT" | grep -q "score"; then
  # Extract top score
  TOP_SCORE=$(echo "$RESULT" | grep -oE "score[^0-9]*[0-9]+\.[0-9]+" | head -1 | grep -oE "[0-9]+\.[0-9]+" || echo "N/A")
  MATCHES=$(echo "$RESULT" | grep -c "path" || echo "0")
  echo "  Results: $MATCHES matches, top score: $TOP_SCORE"
  else
  echo "  No results or error"
  fi
  echo ""
done

# Check memory status
echo "=== Memory Index Status ==="
hermes memory status 2>&1 | grep -E "(Indexed|Vector|FTS|Provider)" || echo "Could not get status"
