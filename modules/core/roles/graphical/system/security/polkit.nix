{ pkgs
, lib
, ...
}: {
  security.polkit.enable = true;

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      hyprpolkitagent;
  };

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland Polkit Authentication Agent";
    partOf = [ "graphical-session.target" ];
    wants = [ "hyprland-session.target" ];
    after = [ "hyprland-session.target" "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
