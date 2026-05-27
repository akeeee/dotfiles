#!/bin/bash
# PostToolUse: Write — auto-create CLAUDE.md when new project init file is written

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH")
DIR=$(dirname "$FILE_PATH")

case "$BASENAME" in
    package.json|pyproject.toml|requirements.txt|Cargo.toml|go.mod) ;;
    *) exit 0 ;;
esac

CLAUDE_MD="$DIR/CLAUDE.md"

# Don't overwrite existing CLAUDE.md
[ -f "$CLAUDE_MD" ] && exit 0

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TEMPLATE="$CLAUDE_DIR/STANDARDS.md"
[ ! -f "$TEMPLATE" ] && exit 0

cp "$TEMPLATE" "$CLAUDE_MD"
echo "✓ Created $CLAUDE_MD from standards template"

# Scaffold nano-staged for JS/TS projects
if [ "$BASENAME" = "package.json" ]; then
    NANOSTAGED="$DIR/.nano-staged.json"
    NANOSTAGED_TEMPLATE="$CLAUDE_DIR/templates/.nano-staged.json"
    if [ ! -f "$NANOSTAGED" ] && [ -f "$NANOSTAGED_TEMPLATE" ]; then
        cp "$NANOSTAGED_TEMPLATE" "$NANOSTAGED"
        echo "✓ Created $NANOSTAGED from template"
    fi
fi
