"use strict";
const vscode = require("vscode");
const lib = require("./lib");

const STATE_KEY = "claudeResetPing.armed"; // { [sessionId]: { message, fireAt: ms | null, name } }
const GRACE_MS = 5000;
const RETRY_LIMIT_MS = 10 * 60 * 1000;

function activate(ctx) {
  const out = vscode.window.createOutputChannel("Claude Reset Ping");
  const bar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 90);
  bar.command = "claudeResetPing.menu";
  ctx.subscriptions.push(out, bar);

  const cfg = () => vscode.workspace.getConfiguration("claudeResetPing");
  const armed = () => ({ ...ctx.globalState.get(STATE_KEY, {}) });
  const save = (a) => ctx.globalState.update(STATE_KEY, a);
  const log = (s) => out.appendLine(`${new Date().toISOString()} ${s}`);

  let usage = null; // {utilization, resetsAt}
  let usageError = null;

  function render() {
    const n = Object.keys(armed()).length;
    const pct = usage ? `${Math.round(usage.utilization)}%` : "?";
    const left = usage && usage.resetsAt ? ` ${lib.fmtDuration(usage.resetsAt - Date.now())}` : "";
    bar.text = `$(pulse) 5h ${pct}${left}${n ? ` $(bell) ${n}` : ""}`;
    bar.tooltip = usageError ? `Usage unavailable: ${usageError}` : "Claude 5h window. Click to manage reset pings.";
    bar.show();
  }

  // Submits a turn into the live session through the patched Claude extension
  // (claude-vscode.sendToSession). Resolves false if the command is missing or
  // the session has no live channel in this window.
  async function deliver(rec, message) {
    try {
      const ok = await vscode.commands.executeCommand("claude-vscode.sendToSession", rec.sessionId, rec.pid, message);
      log(`send ${rec.name || rec.sessionId}: ${ok ? "ok" : "no live channel"}`);
      return ok === true;
    } catch (e) {
      log(`send failed: ${e.message}`);
      return false;
    }
  }

  // Fires every armed session whose reset has passed. force=true treats the
  // reset as having just passed, and runs the exact same send/disarm path.
  async function fireDue(force = false) {
    const a = armed();
    const live = new Map(lib.liveSessions().map((r) => [r.sessionId, r]));
    let dirty = false;
    const now = Date.now();
    for (const [id, s] of Object.entries(a)) {
      // Arm against the current window as soon as one is known.
      if (!force && s.fireAt == null && usage && usage.resetsAt) {
        s.fireAt = usage.resetsAt;
        dirty = true;
        log(`armed ${s.name || id} for ${new Date(s.fireAt).toISOString()}`);
      }
      const fireAt = force ? now - GRACE_MS : s.fireAt;
      if (fireAt == null || now < fireAt + GRACE_MS) continue;

      const rec = live.get(id);
      const late = now - fireAt;
      if (rec && rec.status === "busy" && late < RETRY_LIMIT_MS) {
        log(`${s.name || id} is busy, waiting`);
        continue;
      }

      if (rec && (await deliver(rec, s.message))) {
        vscode.window.showInformationMessage(`Sent "${s.message}" to ${s.name || id}`);
        if (cfg().get("rearm", false)) s.fireAt = null;
        else delete a[id];
        dirty = true;
      } else if (!rec && late >= RETRY_LIMIT_MS) {
        // Only give up when the session process is gone. A live session whose
        // channel lives in another window is that window's to deliver.
        vscode.window.showWarningMessage(`Reset ping to ${s.name || id} failed; session no longer running. Disarmed.`);
        delete a[id];
        dirty = true;
      }
    }
    if (dirty) await save(a);
  }

  // Prefer the CLI-owned windows the sidebar meter uses (patched command, no extra
  // requests); fall back to our own rate-limited, cached endpoint call.
  let loggedShape = false;
  async function readUsage() {
    try {
      const raw = await vscode.commands.executeCommand("claude-vscode.getUsage");
      if (raw) {
        if (!loggedShape) (loggedShape = true), log(`usage via claude: ${JSON.stringify(raw).slice(0, 300)}`);
        const u = lib.parseUsage(raw);
        if (u.resetsAt || u.utilization) return u;
      }
    } catch (e) {
      log(`getUsage command unavailable: ${e.message}`);
    }
    return lib.fetchFiveHour();
  }

  async function tick() {
    try {
      usage = await readUsage();
      usageError = null;
    } catch (e) {
      usageError = e.message;
    }

    await fireDue();
    render();
  }

  async function menu() {
    const a = armed();
    const live = lib.liveSessions();
    const ids = new Set(live.map((r) => r.sessionId));
    const rows = live.map((r) => ({ id: r.sessionId, name: r.name || r.sessionId.slice(0, 8), cwd: r.cwd }));
    for (const [id, s] of Object.entries(a)) if (!ids.has(id)) rows.push({ id, name: s.name || id.slice(0, 8), cwd: undefined });

    const pick = await vscode.window.showQuickPick(
      rows.map((r) => ({
        label: `${a[r.id] ? "$(bell) " : "$(circle-outline) "}${r.name}`,
        description: a[r.id] ? `"${a[r.id].message}"` : "off",
        detail: r.cwd,
        r,
      })),
      { title: "Send message at 5h reset", placeHolder: "Pick a session" },
    );
    if (!pick) return;
    const { r } = pick;
    const cur = a[r.id];
    const act = await vscode.window.showQuickPick(
      [
        { label: cur ? "$(bell-slash) Turn off" : "$(bell) Turn on", k: "toggle" },
        { label: "$(edit) Set message", k: "msg" },
      ],
      { title: r.name },
    );
    if (!act) return;

    if (act.k === "toggle" && cur) {
      delete a[r.id];
    } else {
      const message = await vscode.window.showInputBox({
        title: `Message for ${r.name}`,
        value: (cur && cur.message) || cfg().get("defaultMessage", "continue"),
      });
      if (!message) return;
      a[r.id] = { message, name: r.name, fireAt: cur ? cur.fireAt : null };
    }
    await save(a);
    await tick();
  }

  async function fireNow() {
    const n = Object.keys(armed()).length;
    if (!n) return vscode.window.showWarningMessage("No sessions armed. Arm one from the status bar first.");
    log(`manual fire of ${n} armed session(s)`);
    await fireDue(true);
    render();
  }

  ctx.subscriptions.push(
    vscode.commands.registerCommand("claudeResetPing.fireNow", fireNow),
    vscode.commands.registerCommand("claudeResetPing.menu", menu),
    vscode.commands.registerCommand("claudeResetPing.refresh", tick),
  );

  let timer;
  const loop = async () => {
    await tick();
    timer = setTimeout(loop, Math.max(15, cfg().get("pollSeconds", 60)) * 1000);
  };
  ctx.subscriptions.push({ dispose: () => clearTimeout(timer) });
  render();
  loop();
}

function deactivate() {}

module.exports = { activate, deactivate };
