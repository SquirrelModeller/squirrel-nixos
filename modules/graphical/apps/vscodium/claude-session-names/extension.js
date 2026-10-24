"use strict";
const fs = require("fs");
const vscode = require("vscode");
const lib = require("./lib");

const POLL_MS = 15000;
const DEBOUNCE_MS = 500;

function activate(ctx) {
  const out = vscode.window.createOutputChannel("Claude Session Names");
  ctx.subscriptions.push(out);
  const enabled = () => vscode.workspace.getConfiguration("claudeSessionNames").get("enabled", true);
  const label = (a) => `${a.rec.name} -> ${a.name}  [pid ${a.rec.pid}, ${a.rec.cwd}]`;

  function restore() {
    if (!enabled()) return;
    for (const a of lib.plan()) {
      if (a.skip) {
        out.appendLine(`skip: ${label(a)} (${a.skip})`);
      } else if (lib.apply(a)) {
        out.appendLine(`restored: ${label(a)}`);
      }
    }
  }

  let timer;
  const schedule = () => {
    clearTimeout(timer);
    timer = setTimeout(restore, DEBOUNCE_MS);
  };

  try {
    const watcher = fs.watch(lib.sessionsDir(), schedule);
    ctx.subscriptions.push({ dispose: () => watcher.close() });
  } catch (e) {
    out.appendLine(`watch failed, polling only: ${e.message}`);
  }
  const poll = setInterval(restore, POLL_MS);
  ctx.subscriptions.push({ dispose: () => (clearInterval(poll), clearTimeout(timer)) });

  ctx.subscriptions.push(
    vscode.commands.registerCommand("claudeSessionNames.restoreNow", () => {
      restore();
      out.show(true);
    }),
    vscode.commands.registerCommand("claudeSessionNames.dryRun", () => {
      const actions = lib.plan();
      out.appendLine(actions.length ? "dry run, would rename:" : "dry run: nothing to rename");
      for (const a of actions) out.appendLine(`  ${a.skip ? "skip " : ""}${label(a)}${a.skip ? ` (${a.skip})` : ""}`);
      out.show(true);
    }),
  );

  restore();
}

function deactivate() {}

module.exports = { activate, deactivate };
