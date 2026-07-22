#!/usr/bin/env node
// grammar-reminder — UserPromptSubmit hook, global (registered in settings.json,
// runs from any cwd). Reminds model to silently correct broken English before
// answering, since hookify's .local.md rules only load relative to session cwd
// and can't cover every project.

let input = '';
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    JSON.parse(input); // validate payload; prompt text itself isn't needed here
    process.stdout.write(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext: "User's English may be broken. If the prompt has grammar errors, " +
          "silently correct it and show it as: grammar fix: 'corrected sentence', then answer " +
          "normally below it. Skip if prompt is already clean English or is a slash-command/" +
          "tool-only instruction."
      }
    }));
  } catch (e) {
    // Silent fail
  }
});
