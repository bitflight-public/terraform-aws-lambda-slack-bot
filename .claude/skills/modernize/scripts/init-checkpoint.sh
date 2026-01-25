#!/bin/bash
#
# Initialize modernization checkpoint document
# Usage: ./init-checkpoint.sh [--force]
#

set -e

CHECKPOINT_FILE="MODERNIZATION_CHECKPOINT.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${SCRIPT_DIR}/checkpoint-template.md"

# Generate session ID
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)-$(head -c 4 /dev/urandom | xxd -p)}"
SESSION_START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REPOSITORY="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"

# Check if checkpoint already exists
if [ -f "$CHECKPOINT_FILE" ] && [ "$1" != "--force" ]; then
    echo "⚠️  Checkpoint already exists at $CHECKPOINT_FILE"
    echo ""
    echo "Options:"
    echo "  - Use '/modernize --resume' to continue from last checkpoint"
    echo "  - Use './init-checkpoint.sh --force' to start fresh"
    echo ""

    # Show current status
    if command -v grep &>/dev/null; then
        echo "Current Status:"
        grep -E "^\| \*\*Total\*\*" "$CHECKPOINT_FILE" 2>/dev/null || echo "  (unable to read status)"
    fi
    exit 0
fi

# Check if template exists
if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Error: Template not found at $TEMPLATE"
    echo "Please ensure the skill is properly installed."
    exit 1
fi

# Create checkpoint from template
echo "🚀 Initializing Brownfield Modernization Checkpoint"
echo ""

cp "$TEMPLATE" "$CHECKPOINT_FILE"

# Replace template variables
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|\${SESSION_ID}|$SESSION_ID|g" "$CHECKPOINT_FILE"
    sed -i '' "s|\${REPOSITORY}|$REPOSITORY|g" "$CHECKPOINT_FILE"
    sed -i '' "s|\${SESSION_START_TIME}|$SESSION_START_TIME|g" "$CHECKPOINT_FILE"
    sed -i '' "s|\${LAST_UPDATED}|$SESSION_START_TIME|g" "$CHECKPOINT_FILE"
else
    # Linux
    sed -i "s|\${SESSION_ID}|$SESSION_ID|g" "$CHECKPOINT_FILE"
    sed -i "s|\${REPOSITORY}|$REPOSITORY|g" "$CHECKPOINT_FILE"
    sed -i "s|\${SESSION_START_TIME}|$SESSION_START_TIME|g" "$CHECKPOINT_FILE"
    sed -i "s|\${LAST_UPDATED}|$SESSION_START_TIME|g" "$CHECKPOINT_FILE"
fi

echo "✅ Checkpoint initialized at $CHECKPOINT_FILE"
echo ""
echo "📋 Session Details:"
echo "   Session ID:  $SESSION_ID"
echo "   Repository:  $REPOSITORY"
echo "   Started:     $SESSION_START_TIME"
echo ""
echo "📊 Next Steps:"
echo "   1. Run '/modernize' to start the modernization workflow"
echo "   2. Agents will update this checkpoint as they work"
echo "   3. Use '/modernize --status' to check progress"
echo ""

# Optionally add to git
if [ -d ".git" ]; then
    echo "💡 Tip: Commit this checkpoint to track progress in git:"
    echo "   git add $CHECKPOINT_FILE && git commit -m 'Initialize modernization checkpoint'"
fi
