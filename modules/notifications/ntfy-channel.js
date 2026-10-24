// MCP server for Claude Code that lets Claude send push notifications to the
// user's phone over ntfy. Optionally (cfg.replies) it also streams replies
// from the reply topic back into the session as <channel> messages.
//
// Config comes from NTFY_CONFIG (generated in ntfy.nix). Speaks
// newline-delimited JSON-RPC on stdio and has no dependencies.

const { execFile } = require("node:child_process");
const fs = require("node:fs");
const readline = require("node:readline");

const cfg = JSON.parse(process.env.NTFY_CONFIG);

const send = (msg) => process.stdout.write(`${JSON.stringify(msg)}\n`);
const log = (...args) => process.stderr.write(`[ntfy-channel] ${args.join(" ")}\n`);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const readToken = () => fs.readFileSync(cfg.tokenFile, "utf8").trim();

const instructions = [
  "Use the notify tool to send the user a push notification on their phone.",
  "Your transcript output never reaches the phone.",
  "Keep notifications short, and only send one when it is needed: a decision, a finished long task, or being blocked.",
  "Markdown is on by default. Use tags sparingly, for example to mark the project or the kind of event.",
].join(" ");

const replyInstructions = [
  `Messages from the user's phone arrive as <channel source="ntfy" ...> on topic ${cfg.replyTopic}.`,
  "Answer them with the notify tool.",
].join(" ");

const tools = [
  {
    name: "notify",
    description:
      "Send a push notification to the user's phone via ntfy. Body supports Markdown unless markdown is false.",
    inputSchema: {
      type: "object",
      properties: {
        message: { type: "string", description: "Notification body" },
        title: { type: "string", description: "Short title, defaults to Claude" },
        priority: {
          type: "integer",
          minimum: 1,
          maximum: 5,
          description: "1 = min, 3 = default, 5 = urgent",
        },
        markdown: { type: "boolean", description: "Render the body as Markdown, default true" },
        tags: {
          type: "array",
          items: { type: "string" },
          description: "ntfy emoji shortcodes shown with the notification, e.g. [\"warning\", \"white_check_mark\"]",
        },
        click_url: { type: "string", description: "URL to open when the notification is tapped" },
      },
      required: ["message"],
    },
  },
];

// Publishing goes through ntfy-send (see ntfy.nix) so the token handling stays in one place.
function notify({ message, title = "Claude", priority = 3, markdown = true, tags = [], click_url }) {
  const args = ["-p", String(priority)];
  if (markdown) args.push("-m");
  if (tags.length > 0) args.push("-t", tags.join(","));
  if (click_url) args.push("-c", click_url);
  args.push(cfg.sendTopic, title, message);

  return new Promise((resolve, reject) => {
    execFile(cfg.sendBin, args, (err, _stdout, stderr) => {
      if (err) reject(new Error(stderr.trim() || err.message));
      else resolve();
    });
  });
}

const toolResult = (text, isError = false) => ({
  content: [{ type: "text", text }],
  ...(isError && { isError: true }),
});

function validateNotifyArgs(args) {
  if (typeof args.message !== "string" || args.message === "") {
    return "message must be a non-empty string";
  }
  if (args.title !== undefined && typeof args.title !== "string") return "title must be a string";
  if (args.tags !== undefined && !(Array.isArray(args.tags) && args.tags.every((t) => typeof t === "string"))) {
    return "tags must be an array of strings";
  }
  if (args.priority !== undefined && !(Number.isInteger(args.priority) && args.priority >= 1 && args.priority <= 5)) {
    return "priority must be an integer from 1 to 5";
  }
  return null;
}

async function handle({ method, params }) {
  switch (method) {
    case "initialize":
      return {
        protocolVersion: params?.protocolVersion,
        capabilities: {
          tools: {},
          // Only advertise the channel when replies are on, otherwise Claude Code
          // would expect pushes this server never sends.
          ...(cfg.replies && { experimental: { "claude/channel": {} } }),
        },
        serverInfo: { name: "ntfy", version: "0.1.0" },
        instructions: cfg.replies ? `${instructions} ${replyInstructions}` : instructions,
      };
    case "tools/list":
      return { tools };
    case "tools/call": {
      const { name, arguments: args = {} } = params ?? {};
      if (name !== "notify") return toolResult(`unknown tool: ${name}`, true);

      const problem = validateNotifyArgs(args);
      if (problem) return toolResult(problem, true);
      try {
        await notify(args);
        return toolResult("sent");
      } catch (err) {
        return toolResult(`notify failed: ${err.message}`, true);
      }
    }
    case "ping":
      return {};
    default:
      throw Object.assign(new Error(`method not found: ${method}`), { code: -32601 });
  }
}

function pushToSession(ev) {
  send({
    jsonrpc: "2.0",
    method: "notifications/claude/channel",
    params: {
      content: ev.message,
      meta: { topic: ev.topic, message_id: ev.id, sent_at: String(ev.time) },
    },
  });
}

// Holds a streaming subscription to the reply topic, reconnecting on failure.
// Starts from "now" so a fresh session does not replay old replies; after that
// it resumes from the last message id, so nothing is delivered twice.
async function subscribe() {
  let since = String(Math.floor(Date.now() / 1000));
  for (;;) {
    try {
      const res = await fetch(`${cfg.serverUrl}/${cfg.replyTopic}/json?since=${since}`, {
        headers: { Authorization: `Bearer ${readToken()}` },
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);

      const decoder = new TextDecoder();
      let buf = "";
      for await (const chunk of res.body) {
        buf += decoder.decode(chunk, { stream: true });
        let nl;
        while ((nl = buf.indexOf("\n")) !== -1) {
          const line = buf.slice(0, nl);
          buf = buf.slice(nl + 1);
          if (!line.trim()) continue;

          const ev = JSON.parse(line);
          if (ev.event === "message" && typeof ev.message === "string") {
            since = ev.id;
            pushToSession(ev);
          }
        }
      }
      log("reply stream closed");
    } catch (err) {
      log("reply subscription failed:", err.message);
    }
    await sleep(5000);
  }
}

const rl = readline.createInterface({ input: process.stdin });
rl.on("line", async (line) => {
  if (!line.trim()) return;

  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    log("ignoring invalid JSON on stdin");
    return;
  }
  // Notifications such as notifications/initialized carry no id and need no reply.
  if (msg.id === undefined) return;

  try {
    send({ jsonrpc: "2.0", id: msg.id, result: await handle(msg) });
  } catch (err) {
    const code = typeof err.code === "number" ? err.code : -32603;
    send({ jsonrpc: "2.0", id: msg.id, error: { code, message: err.message } });
  }
});
// Claude Code closes stdin when the session ends; exit with it.
rl.on("close", () => process.exit(0));

if (cfg.replies) subscribe();
