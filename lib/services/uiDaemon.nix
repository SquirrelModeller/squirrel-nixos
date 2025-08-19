{ config
, lib
, ...
}:
let
  cfg = config.modules.usrEnv.services.uiDaemon;
in
{
  options.modules.usrEnv.services.uiDaemon = {
    enable = lib.mkEnableOption "Enable a user-level UI daemon";
    package = lib.mkOption {
      type = lib.types.package;
      description = "The package providing the UI daemon binary";
    };
    command = lib.mkOption {
      type = lib.types.str;
      description = "Command to run";
    };
    afterGraphical = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start only after graphical-session.target";
    };
    restartOnFailure = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically restart the daemon on failure";
    };
    isDaemon = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "True assumes the command is a long-lived daemon. False treats it as a one-shot command.";
    };
    dependencies = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to be available in the PATH for the service";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.ui-daemon = {
      Unit = {
        Description = "User UI Daemon";
        # TODO: Generalize session target!
        # I have not gotten around to generalize this for multiple WMS
        After = (lib.optional cfg.afterGraphical "graphical-session.target") ++ [ "hyprland-session.target" ];
        PartOf = (lib.optional cfg.afterGraphical "graphical-session.target") ++ [ "hyprland-session.target" ];
        Requires = [ "hyprland-session.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/${cfg.command}";
        Type =
          if cfg.isDaemon
          then "exec"
          else "oneshot";
        RemainAfterExit = !cfg.isDaemon;
        Restart =
          if cfg.restartOnFailure && cfg.isDaemon
          then "on-failure"
          else "no";
        RestartSec = 5;
        EnvironmentFile = "-/etc/environment";
        PassEnvironment = "PATH";
        Environment = [
          "XDG_RUNTIME_DIR=%t"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
