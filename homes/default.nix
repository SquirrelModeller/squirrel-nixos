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

  home.packages = with pkgs; [
    hyprpaper
    htop
    grim
    slurp
    wl-clipboard
    fastfetch
    socat
    inputs.alejandra.defaultPackage.${pkgs.system}
    nixpkgs-fmt
    vlc
    playerctl
  ];

  home.stateVersion = "24.11";
}
