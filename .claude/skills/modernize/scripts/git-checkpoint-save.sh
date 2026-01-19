#!/bin/bash
#
# Auto-save checkpoint to git on session end
# Called by Claude Code Stop hook
#

CHECKPOINT_FILE="MODERNIZATION_CHECKPOINT.md"

# Exit silently if no checkpoint exists
if [ ! -f "$CHECKPOINT_FILE" ]; then
    exit 0
fi

# Exit silently if not in a git repository
if [ ! -d ".git" ]; then
    exit 0
fi

# Check if there are changes to the checkpoint
if git diff --quiet "$CHECKPOINT_FILE" 2>/dev/null; then
    # No changes, exit silently
    exit 0
fi

# Stage and commit the checkpoint
git add "$CHECKPOINT_FILE"

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
git commit -m "Auto-save modernization checkpoint at $TIMESTAMP" --no-verify 2>/dev/null || true

echo "💾 Checkpoint auto-saved to git"
