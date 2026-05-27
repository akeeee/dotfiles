#!/bin/bash
# PostToolUse: Write/Edit — lint file immediately after Claude writes it

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
[ ! -f "$FILE_PATH" ] && exit 0

OXLINT=$(command -v oxlint 2>/dev/null || echo "npx --yes oxlint")

case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
        $OXLINT --fix "$FILE_PATH" 2>&1
        ;;
esac
