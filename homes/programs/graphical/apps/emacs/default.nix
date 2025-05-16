{ lib
, osConfig
, pkgs
, inputs
, ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;
  env = modules.usrEnv;

  devTools = with pkgs; [
    clang-tools
    rust-analyzer
    nil
    nodePackages.typescript-language-server
    nodePackages.bash-language-server
    inputs.quickshell
    nodePackages.vscode-langservers-extracted
  ];
  emacsWrapped = pkgs.symlinkJoin {
    name = "emacs-wrapped";
    paths = [ pkgs.emacs ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/emacs \
        --suffix PATH : "${lib.makeBinPath devTools}"
    '';
    meta = pkgs.emacs.meta // {
      description = "Emacs wrapped with language server tools";
    };
  };

in
{
  imports = [
    ./themes/generate-theme.nix
  ];
  config = mkIf env.programs.apps.emacs.enable {
    programs.emacs = {
      enable = true;
      package = emacsWrapped;
      extraPackages = epkgs: with epkgs; [
        use-package
        format-all
        all-the-icons
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
        lsp-mode
        lsp-ui
        lsp-pyright
        which-key
        company-box
        markdown-mode
        markdown-preview-mode
        markdown-toc
      ];
    };

    home.activation.tangleEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Tangling Emacs config.org..."
      ${emacsWrapped}/bin/emacs --batch \
        --eval "(require 'org)" \
        --eval "(org-babel-tangle-file \"$HOME/.config/emacs/config.org\")"
    '';

    home.file = {
      ".config/emacs/config.org".source = ./config.org;
      ".config/emacs/early-init.el".text = ''
        (setq user-emacs-directory "~/.config/emacs/")
        (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
        (when (file-exists-p custom-file)
          (load custom-file nil t))

        (setq package-enable-at-startup nil)

        (push '(menu-bar-lines . 0) default-frame-alist)
        (push '(tool-bar-lines . 0) default-frame-alist)
        (push '(vertical-scroll-bars) default-frame-alist)

        (setq frame-inhibit-implied-resize t)

        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (setq inhibit-splash-screen t)
        (setq use-dialog-box nil)

        (setq gc-cons-threshold most-positive-fixnum)
        (setq gc-cons-percentage 0.6)

        (load-file (expand-file-name "config.el" user-emacs-directory))
      '';
    };

    #xdg.configFile."emacs/themes/my-kitty-theme.el".source = ./themes/my-kitty-theme.el;
  };
}
