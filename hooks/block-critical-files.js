#!/usr/bin/env node
// PreToolUse: Edit/Write — block edits to critical files
const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'))
const filePath = data.tool_input?.file_path || ''

const blocked = [
  '.env', '.env.local', '.env.production', '.env.staging',
  'Gemfile.lock', 'yarn.lock', 'package-lock.json', 'pnpm-lock.yaml',
  'credentials.yml', 'credentials.yml.enc', 'master.key',
  'id_rsa', 'id_ed25519', '.pem', '.p12',
]

const isBlocked = blocked.some(pattern =>
  filePath.endsWith(pattern) || filePath.includes('/' + pattern)
)

if (isBlocked) {
  console.error(`BLOCKED: ${filePath} requires manual editing`)
  process.exit(2)
}
