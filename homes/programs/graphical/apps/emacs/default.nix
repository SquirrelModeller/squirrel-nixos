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

  tree-sitter-parsers = grammars: with grammars; [
    tree-sitter-bash
    tree-sitter-c
    tree-sitter-cpp
    tree-sitter-css
    tree-sitter-html
    tree-sitter-javascript
    tree-sitter-json
    tree-sitter-python
    tree-sitter-rust
    tree-sitter-tsx
    tree-sitter-typescript
    tree-sitter-nix
    inputs.nix-qml-support.packages.${pkgs.stdenv.system}.tree-sitter-qmljs
  ];

  devTools = with pkgs; [
    clang-tools
    rust-analyzer
    nil
    nodePackages.typescript-language-server
    nodePackages.bash-language-server
    inputs.quickshell
    nodePackages.vscode-langservers-extracted
    qt6.qtdeclarative
  ];

  custom-emacs = with pkgs;
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: with epkgs; [
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
      neotree
      minimap
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

      (treesit-grammars.with-grammars (grammars: tree-sitter-parsers grammars))
      inputs.nix-qml-support.packages.${pkgs.stdenv.system}.qml-ts-mode
    ]));

  emacsWrapped = pkgs.symlinkJoin {
    name = "emacs-wrapped";
    paths = [ custom-emacs ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/emacs \
        --suffix PATH : "${lib.makeBinPath devTools}"
    '';
    meta = custom-emacs.meta // {
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


    # home.sessionVariables = {
    #   QML2_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml";
    # };
  };
}
