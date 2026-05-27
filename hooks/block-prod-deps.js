#!/usr/bin/env node
// PreToolUse: Bash — block production dependency installs without approval
const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'))
const cmd = data.tool_input?.command || ''

// Allow dev deps (-D / --save-dev / --dev), block prod installs
const prodInstall = /\b(npm install|npm i|yarn add|pnpm add|gem install|pip install)\b/.test(cmd)
const isDevOnly = /(\s(-D|--save-dev|--dev)\b)/.test(cmd)

if (prodInstall && !isDevOnly) {
  console.error(`BLOCKED: production dep install requires manual approval.\nRun manually if intended: ${cmd}`)
  process.exit(2)
}
