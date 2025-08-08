{ pkgs, inputs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
  };

  imports = [
    ../lib/services/uiDaemon.nix
    ./services/wayland/hyprpaper/default.nix
    ./services/eww/default.nix
    ./services/quickshell/default.nix
    ./programs
    ./themes/gtk.nix
  ];

  home.stateVersion = "24.11";
}
