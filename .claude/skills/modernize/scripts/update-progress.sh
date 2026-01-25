#!/bin/bash
#
# Update modernization checkpoint progress
# Usage: ./update-progress.sh <task_id> <status> [notes]
#
# Examples:
#   ./update-progress.sh ARCH-001 completed "Found 12 modules, 45 functions"
#   ./update-progress.sh SEC-001 in_progress "Running security scan"
#   ./update-progress.sh TEST-001 blocked "Missing pytest dependency"
#

set -e

CHECKPOINT_FILE="MODERNIZATION_CHECKPOINT.md"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <task_id> <status> [notes]"
    echo ""
    echo "Arguments:"
    echo "  task_id  - Task identifier (e.g., ARCH-001, SEC-001)"
    echo "  status   - One of: pending, in_progress, completed, blocked"
    echo "  notes    - Optional notes about the update"
    echo ""
    echo "Examples:"
    echo "  $0 ARCH-001 completed 'Inventory complete: 12 modules'"
    echo "  $0 SEC-001 in_progress 'Running bandit scan'"
    exit 1
fi

TASK_ID="$1"
STATUS="$2"
NOTES="${3:-}"

# Validate status
case "$STATUS" in
    pending | in_progress | completed | blocked) ;;
    *)
        echo "❌ Invalid status: $STATUS"
        echo "   Valid values: pending, in_progress, completed, blocked"
        exit 1
        ;;
esac

# Check if checkpoint exists
if [ ! -f "$CHECKPOINT_FILE" ]; then
    echo "❌ Checkpoint not found at $CHECKPOINT_FILE"
    echo "   Run '/modernize --init' first to create a checkpoint."
    exit 1
fi

# Map status to checkbox
case "$STATUS" in
    completed)
        CHECKBOX="[x]"
        STATUS_EMOJI="✅"
        ;;
    in_progress)
        CHECKBOX="[~]"
        STATUS_EMOJI="🔄"
        ;;
    blocked)
        CHECKBOX="[!]"
        STATUS_EMOJI="🚫"
        ;;
    *)
        CHECKBOX="[ ]"
        STATUS_EMOJI="⏳"
        ;;
esac

# Update the task checkbox in the checklist
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/- \[.\] \*\*${TASK_ID}\*\*/- ${CHECKBOX} **${TASK_ID}**/" "$CHECKPOINT_FILE"
    sed -i '' "s|\${LAST_UPDATED}|$TIMESTAMP|g" "$CHECKPOINT_FILE"
    # Update the Last Updated field
    sed -i '' "s/^\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $TIMESTAMP/" "$CHECKPOINT_FILE"
else
    # Linux
    sed -i "s/- \[.\] \*\*${TASK_ID}\*\*/- ${CHECKBOX} **${TASK_ID}**/" "$CHECKPOINT_FILE"
    sed -i "s|\${LAST_UPDATED}|$TIMESTAMP|g" "$CHECKPOINT_FILE"
    sed -i "s/^\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $TIMESTAMP/" "$CHECKPOINT_FILE"
fi

# Add entry to appropriate section based on status
if [ "$STATUS" = "completed" ]; then
    # Add to Completed Tasks section
    ENTRY="- **${TASK_ID}** - Completed at $TIMESTAMP"
    [ -n "$NOTES" ] && ENTRY="$ENTRY - $NOTES"

    # Insert after "## Completed Tasks" header
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^## Completed Tasks$/a\\
\\
$ENTRY" "$CHECKPOINT_FILE"
    else
        sed -i "/^## Completed Tasks$/a\\$ENTRY" "$CHECKPOINT_FILE"
    fi

    # Remove from In Progress if it was there
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^- \*\*${TASK_ID}\*\* - Started/d" "$CHECKPOINT_FILE"
    else
        sed -i "/^- \*\*${TASK_ID}\*\* - Started/d" "$CHECKPOINT_FILE"
    fi
fi

if [ "$STATUS" = "in_progress" ]; then
    # Add to In Progress Tasks section
    ENTRY="- **${TASK_ID}** - Started at $TIMESTAMP"
    [ -n "$NOTES" ] && ENTRY="$ENTRY - $NOTES"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^## In Progress Tasks$/a\\
\\
$ENTRY" "$CHECKPOINT_FILE"
    else
        sed -i "/^## In Progress Tasks$/a\\$ENTRY" "$CHECKPOINT_FILE"
    fi
fi

if [ "$STATUS" = "blocked" ]; then
    # Add to Blocked Tasks section
    ENTRY="- **${TASK_ID}** - Blocked at $TIMESTAMP"
    [ -n "$NOTES" ] && ENTRY="$ENTRY - Reason: $NOTES"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^## Blocked Tasks$/a\\
\\
$ENTRY" "$CHECKPOINT_FILE"
    else
        sed -i "/^## Blocked Tasks$/a\\$ENTRY" "$CHECKPOINT_FILE"
    fi
fi

echo "$STATUS_EMOJI Task $TASK_ID updated to: $STATUS"
[ -n "$NOTES" ] && echo "   Notes: $NOTES"
echo "   Timestamp: $TIMESTAMP"
