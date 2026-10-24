{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.squirrelOS.notifications.ntfy;

  tokenPath = config.age.secrets.ntfy-token.path;

  # usage: ntfy-send [-p priority 1-5] [-m] [-t tags] [-c click-url] <topic> <title> <message>
  #   -m  render the body as Markdown
  #   -t  comma-separated ntfy tags (emoji shortcodes, e.g. warning,white_check_mark)
  #   -c  URL to open when the notification is tapped
  ntfySend = pkgs.writeShellApplication {
    name = "ntfy-send";
    runtimeInputs = [pkgs.curl];
    text = ''
      priority=3
      markdown=0
      tags=""
      click=""

      while getopts "p:mt:c:" opt; do
        case $opt in
          p) priority=$OPTARG ;;
          m) markdown=1 ;;
          t) tags=$OPTARG ;;
          c) click=$OPTARG ;;
          *) echo "usage: ntfy-send [-p priority] [-m] [-t tags] [-c click-url] <topic> <title> <message>" >&2; exit 2 ;;
        esac
      done
      shift $((OPTIND - 1))

      topic=''${1:?topic missing}
      title=''${2:?title missing}
      message=''${3:?message missing}

      token=$(tr -d '\n' < "${tokenPath}")

      # --data-raw so a message starting with "@" is sent as text, not read as a file.
      args=(
        -fsS --max-time 10
        -H "Authorization: Bearer $token"
        -H "X-Title: $title"
        -H "X-Priority: $priority"
        --data-raw "$message"
      )
      if [[ $markdown == 1 ]]; then
        args+=(-H "X-Markdown: yes")
      fi
      if [[ -n $tags ]]; then
        args+=(-H "X-Tags: $tags")
      fi
      if [[ -n $click ]]; then
        args+=(-H "X-Click: $click")
      fi

      curl "''${args[@]}" "${cfg.serverUrl}/$topic"
    '';
  };

  # Claude Code Notification hook: reads the event JSON on stdin and forwards it.
  claudeNotifyHook = pkgs.writeShellApplication {
    name = "claude-notify-hook";
    runtimeInputs = [pkgs.jq ntfySend];
    text = ''
      input=$(cat)
      message=$(jq -r '.message // "Needs your attention"' <<<"$input")
      project=$(jq -r '.cwd // "" | split("/") | last' <<<"$input")

      title="Claude"
      if [[ -n $project ]]; then
        title="Claude: $project"
      fi

      ntfy-send -p 4 -t warning ${cfg.sendTopic} "$title" "$message" || true
    '';
  };

  # MCP server exposing the notify tool, plus replies when enabled (see ntfy-channel.js).
  channelServer = pkgs.writeScriptBin "ntfy-channel" (
    "#!${pkgs.nodejs}/bin/node\n" + builtins.readFile ./ntfy-channel.js
  );

  # Loaded by claude-session-wrapper with --mcp-config.
  channelMcpConfig = pkgs.writeText "ntfy-channel-mcp.json" (builtins.toJSON {
    mcpServers.ntfy = {
      type = "stdio";
      command = "${channelServer}/bin/ntfy-channel";
      args = [];
      env.NTFY_CONFIG = builtins.toJSON {
        inherit (cfg) serverUrl sendTopic replyTopic;
        replies = cfg.replies.enable;
        tokenFile = tokenPath;
        sendBin = "${ntfySend}/bin/ntfy-send";
      };
    };
  });
in {
  options.squirrelOS.notifications.ntfy = {
    enable = lib.mkEnableOption "ntfy notifications";

    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.talosvault.net";
      description = "ntfy server URL";
    };

    sendTopic = lib.mkOption {
      type = lib.types.str;
      default = "claude";
      description = "Topic Claude notifications are published to";
    };

    replyTopic = lib.mkOption {
      type = lib.types.str;
      default = "claude-reply";
      description = ''
        Topic replies are published to. Only used when replies.enable is set, and then
        the ntfy token needs read access to it.
      '';
    };

    notifyRebuild = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Send a notification after each system rebuild";
    };

    claudeChannel.enable = lib.mkEnableOption ''
      the Claude notify tool. Claude Code picks it up through /etc/claude-code/ntfy-channel.json,
      which claude-session-wrapper loads
    '';

    replies.enable = lib.mkEnableOption ''
      replies from the phone (replyTopic) pushed into Claude sessions. Off by default: every
      running session subscribes, so each reply would reach all of them
    '';
  };

  config = lib.mkIf cfg.enable {
    age.secrets.ntfy-token = {
      file = "${self}/secrets/ntfy-token.age";
      owner = "squirrel";
      mode = "400";
    };

    environment.systemPackages = [
      ntfySend
      claudeNotifyHook
    ];

    environment.etc = lib.mkMerge [
      (lib.mkIf cfg.claudeChannel.enable {
        "claude-code/ntfy-channel.json".source = channelMcpConfig;
      })
      # Marker read by claude-session-wrapper: only then pass the development-channel flag.
      (lib.mkIf (cfg.claudeChannel.enable && cfg.replies.enable) {
        "claude-code/ntfy-replies".text = "";
      })
    ];

    system.activationScripts.ntfyRebuildNotify = lib.mkIf cfg.notifyRebuild {
      deps = ["agenixInstall"];
      text = ''
        ${ntfySend}/bin/ntfy-send -p 3 rebuild "System rebuilt" "NixOS configuration on ${config.networking.hostName} was rebuilt at $(date '+%Y-%m-%d %H:%M:%S')" || true
      '';
    };
  };
}
