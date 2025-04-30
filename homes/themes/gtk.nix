{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in {
  config = mkIf env.style.gtk.enable {
    home.packages = with pkgs; [
      catppuccin-gtk
      catppuccin-cursors
      catppuccin-papirus-folders
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
    ];

    gtk = {
      enable = true;

      theme = {
        name = "catppuccin-mocha-rosewater-standard";
        package = pkgs.catppuccin-gtk.override {
          accents = ["rosewater"];
          variant = "mocha";
        };
      };

      cursorTheme = {
        name = "catppuccin-mocha-dark-cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        # gtk-theme = "catppuccin-mocha-rosewater-standard";
        cursor-theme = "catppuccin-mocha-dark-cursors";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "''";
      };
    };
  };
}
