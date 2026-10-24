"use strict";
// Restores user-chosen Claude Code session names into the live session registry.
//
// The CLI persists `agent-name` / `custom-title` entries in each session's
// transcript, but after a relaunch it registers a *derived* name
// (e.g. "helkos-mountain-generation-2f") in ~/.claude/sessions/<pid>.json.
// That registry name is what `list-agents` and cross-session messaging use.

const fs = require("fs");
const os = require("os");
const path = require("path");

const claudeDir = () => path.join(os.homedir(), ".claude");
const sessionsDir = () => path.join(claudeDir(), "sessions");
const projectsDir = () => path.join(claudeDir(), "projects");

function isAlive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch (e) {
    return e.code === "EPERM";
  }
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return undefined;
  }
}

function readSessions() {
  let files;
  try {
    files = fs.readdirSync(sessionsDir());
  } catch {
    return [];
  }
  const out = [];
  for (const f of files) {
    if (!/^\d+\.json$/.test(f)) continue;
    const file = path.join(sessionsDir(), f);
    const rec = readJson(file);
    if (rec && typeof rec.pid === "number") out.push({ file, rec });
  }
  return out;
}

// Claude Code encodes a cwd as a project dir name by replacing every
// non-alphanumeric character with "-".
const encodeCwd = (cwd) => cwd.replace(/[^a-zA-Z0-9]/g, "-");

function findTranscript(rec) {
  if (!rec.sessionId) return undefined;
  const direct = path.join(projectsDir(), encodeCwd(rec.cwd ?? ""), `${rec.sessionId}.jsonl`);
  if (fs.existsSync(direct)) return direct;
  try {
    for (const d of fs.readdirSync(projectsDir())) {
      const p = path.join(projectsDir(), d, `${rec.sessionId}.jsonl`);
      if (fs.existsSync(p)) return p;
    }
  } catch {}
  return undefined;
}

// Last value of a `{"type":<type>,...,<key>:"..."}` line. Entries are
// re-appended throughout the transcript, so the last one is the current name.
function lastEntry(text, type, key) {
  const marker = `"type":"${type}"`;
  let from = text.length;
  while (true) {
    const at = text.lastIndexOf(marker, from);
    if (at < 0) return undefined;
    const start = text.lastIndexOf("\n", at) + 1;
    let end = text.indexOf("\n", at);
    if (end < 0) end = text.length;
    try {
      const v = JSON.parse(text.slice(start, end))[key];
      if (typeof v === "string" && v.trim()) return v.trim();
    } catch {}
    from = at - 1;
    if (from < 0) return undefined;
  }
}

// Same precedence as the CLI's own display name: agentName, then customTitle.
// ai-title is auto-generated and deliberately ignored.
function storedName(transcript) {
  let text;
  try {
    text = fs.readFileSync(transcript, "utf8");
  } catch {
    return undefined;
  }
  return lastEntry(text, "agent-name", "agentName") ?? lastEntry(text, "custom-title", "customTitle");
}

// Sessions whose registry name is auto-derived and whose transcript holds a
// user-chosen name. Pure read: nothing is written.
function plan() {
  const sessions = readSessions().filter(({ rec }) => isAlive(rec.pid));
  const taken = new Set(sessions.filter(({ rec }) => rec.nameSource === "user").map(({ rec }) => rec.name));
  const actions = [];
  for (const { file, rec } of sessions) {
    if (rec.entrypoint !== "claude-vscode") continue;
    if (rec.nameSource === "user") continue;
    const transcript = findTranscript(rec);
    const name = transcript && storedName(transcript);
    if (!name || name === rec.name) continue;
    if (taken.has(name)) {
      actions.push({ file, rec, name, skip: `name "${name}" already used by another live session` });
      continue;
    }
    taken.add(name);
    actions.push({ file, rec, name });
  }
  return actions;
}

// Re-reads the record right before writing so a concurrent CLI update (or a
// rename the user just made) is never clobbered, then replaces it atomically.
function apply(action) {
  const cur = readJson(action.file);
  if (!cur || cur.sessionId !== action.rec.sessionId || cur.nameSource === "user") return false;
  const next = { ...cur, name: action.name, nameSource: "user", nameSince: Date.now() };
  const tmp = `${action.file}.tmp-${process.pid}`;
  try {
    fs.writeFileSync(tmp, JSON.stringify(next), { mode: 0o644 });
    fs.renameSync(tmp, action.file);
    return true;
  } catch {
    try {
      fs.unlinkSync(tmp);
    } catch {}
    return false;
  }
}

module.exports = { plan, apply, sessionsDir, encodeCwd, lastEntry };
