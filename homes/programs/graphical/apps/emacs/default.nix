{ config
, lib
, osConfig
, pkgs
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  env = modules.usrEnv;
in
{
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
          org
          org-bullets
          org-modern
          org-present
          ox-reveal
          htmlize
        ];
    };

    home.activation.tangleEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Tangling Emacs config.org..."
      ${pkgs.emacs}/bin/emacs --batch \
        --eval "(require 'org)" \
        --eval "(org-babel-tangle-file \"$HOME/.config/emacs/config.org\")"
    '';

    home.file = {
      ".config/emacs/config.org".source = ./config.org;
      ".config/emacs/early-init.el".text = ''
        ;;; early-init.el --- Load config
        (setq user-emacs-directory "~/.config/emacs/")
        (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
        (when (file-exists-p custom-file)
          (load custom-file nil t))
        (load-file (expand-file-name "config.el" user-emacs-directory))
        ;;; early-init.el ends here
      '';
    };

    xdg.configFile."emacs/themes/my-kitty-theme.el".source = ./themes/my-kitty-theme.el;
  };
}
