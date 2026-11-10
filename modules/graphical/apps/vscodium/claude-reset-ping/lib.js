"use strict";
const fs = require("fs");
const os = require("os");
const path = require("path");

const claudeDir = () => path.join(os.homedir(), ".claude");

function readToken() {
  const c = JSON.parse(fs.readFileSync(path.join(claudeDir(), ".credentials.json"), "utf8"));
  return c.claudeAiOauth && c.claudeAiOauth.accessToken;
}

// Usage is shared across every Codium window through a small cache file, so N
// windows make one request per interval instead of N, and a 429 backs all of
// them off together.
const cacheFile = () => path.join(os.homedir(), ".cache", "claude-reset-ping", "usage.json");
const readCache = () => {
  try {
    return JSON.parse(fs.readFileSync(cacheFile(), "utf8"));
  } catch {
    return {};
  }
};
const writeCache = (c) => {
  try {
    fs.mkdirSync(path.dirname(cacheFile()), { recursive: true });
    fs.writeFileSync(cacheFile(), JSON.stringify(c));
  } catch {}
};

// Returns {utilization (0-100), resetsAt (ms) | null}. Throws on HTTP/auth errors.
// Serves the cache while it is younger than minAgeMs or while backing off.
async function fetchFiveHour(minAgeMs = 180000) {
  const c = readCache();
  const now = Date.now();
  if (c.usage && (now - c.fetchedAt < minAgeMs || now < (c.backoffUntil || 0))) return c.usage;
  if (now < (c.backoffUntil || 0)) throw new Error(`rate limited, retrying in ${fmtDuration(c.backoffUntil - now)}`);

  const token = readToken();
  if (!token) throw new Error("no access token");
  const r = await fetch("https://api.anthropic.com/api/oauth/usage", {
    headers: { Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20" },
  });
  if (r.status === 429) {
    const ra = Number(r.headers.get("retry-after"));
    const wait = Math.min(Math.max(Number.isFinite(ra) && ra > 0 ? ra * 1000 : 0, 2 * 60000), 30 * 60000);
    writeCache({ ...c, backoffUntil: now + wait });
    if (c.usage) return c.usage;
    throw new Error(`usage endpoint 429, backing off ${fmtDuration(wait)}`);
  }
  if (!r.ok) throw new Error(`usage endpoint ${r.status}`);
  const usage = parseUsage(await r.json());
  writeCache({ usage, fetchedAt: now });
  return usage;
}

// Accepts the raw endpoint shape (resets_at ISO string, utilization in percent)
// and the CLI relay shape (resetsAt in epoch seconds, utilization 0-1).
function parseUsage(j) {
  const f = j && j.five_hour;
  if (!f || typeof f.utilization !== "number") return { utilization: 0, resetsAt: null };
  let t = NaN;
  if (typeof f.resets_at === "string") t = Date.parse(f.resets_at);
  else if (typeof f.resetsAt === "number") t = f.resetsAt * 1000;
  const pct = f.resetsAt !== undefined && f.resets_at === undefined && f.utilization <= 1 ? f.utilization * 100 : f.utilization;
  return { utilization: pct, resetsAt: Number.isFinite(t) ? t : null };
}

function isAlive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch (e) {
    return e.code === "EPERM";
  }
}

// Live Claude sessions from the registry, one per sessionId.
function liveSessions() {
  const dir = path.join(claudeDir(), "sessions");
  const out = new Map();
  let files = [];
  try {
    files = fs.readdirSync(dir).filter((f) => /^\d+\.json$/.test(f));
  } catch {
    return [];
  }
  for (const f of files) {
    try {
      const r = JSON.parse(fs.readFileSync(path.join(dir, f), "utf8"));
      if (r.sessionId && r.kind === "interactive" && isAlive(r.pid)) out.set(r.sessionId, r);
    } catch {}
  }
  return [...out.values()].sort((a, b) => String(a.name).localeCompare(String(b.name)));
}

function fmtDuration(ms) {
  if (ms <= 0) return "now";
  const m = Math.round(ms / 60000);
  return m >= 60 ? `${Math.floor(m / 60)}h${String(m % 60).padStart(2, "0")}m` : `${m}m`;
}

module.exports = { fetchFiveHour, parseUsage, liveSessions, fmtDuration, isAlive };
