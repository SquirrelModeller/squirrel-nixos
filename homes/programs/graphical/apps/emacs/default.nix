{
  config,
  lib,
  osConfig,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  env = modules.usrEnv;
in {
  config = mkIf env.programs.apps.emacs.enable {
    programs.emacs = {
      enable = true;
      extraPackages = epkgs:
        with epkgs; [
          use-package
          format-all
          nix-mode
          dashboard
          elscreen
          flycheck
          workgroups2
          rainbow-mode
          multiple-cursors
          company
          qml-mode
          neotree
          minimap
          all-the-icons
        ];
      extraConfig = builtins.readFile ./.emacs;
    };

    xdg.configFile."emacs/themes/my-kitty-theme.el".text =
      builtins.readFile ./themes/my-kitty-theme.el;
  };
}
