{ pkgs, inputs, lib, colors, ... }:
let

  # This is temporary. I finally got this shit working.
  # Moving this to a seperate file later. Eventually...
  emacsThemeText = import ./emacs/themes/generate-theme.nix { inherit lib colors; };
  emacsThemFile = pkgs.writeText "my-kitty-theme.el" emacsThemeText;

  treeSitterParsers = grammars: with grammars; [
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
    nodePackages.vscode-langservers-extracted
    qt6.qtdeclarative
  ];

  customEmacs =
    (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: with epkgs; [
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
      direnv
      (treesit-grammars.with-grammars (grammars: treeSitterParsers grammars))
      inputs.nix-qml-support.packages.${pkgs.stdenv.system}.qml-ts-mode
    ]);

  emacsInitDir = pkgs.stdenv.mkDerivation {
    pname = "emacs-init-squirrel";
    version = "1";
    src = ./emacs;

    nativeBuildInputs = [ customEmacs pkgs.coreutils ];

    installPhase = ''
       mkdir -p $out
       cp -r ./* $out/

       # Tangle config.org -> config.el inside $out
       ${customEmacs}/bin/emacs --batch \
         --eval "(require 'org)" \
         --eval "(org-babel-tangle-file \"$out/config.org\" \"$out/config.el\")"

      mkdir -p $out/themes
       cp ${emacsThemFile} $out/themes/my-kitty-theme.el
    '';
  };
  #temo
  emacsWrapped = pkgs.symlinkJoin {
    name = "emacs-wrapped";
    paths = [ customEmacs ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/emacs \
        --suffix PATH : "${lib.makeBinPath devTools}" \
        --add-flags "--init-directory ${emacsInitDir}"
    '';
    meta = customEmacs.meta // {
      description = "Emacs wrapped with language servers and init directory";
    };
  };






in
with pkgs; [
  # TODO: Fix emacs temp file folder source
  emacsWrapped
  hyprpaper
  htop
  grim
  slurp
  wl-clipboard
  fastfetch
  socat
  nixpkgs-fmt
  vlc
  playerctl
  pandoc
  kitty
  inputs.quickshell.packages.${pkgs.system}.default
  inputs.alejandra.defaultPackage.${pkgs.system}
  hyprpaper
  blender-hip
  tofi
  tree
  ranger

  (wrapOBS {
    plugins = with obs-studio-plugins; [
      wlrobs
      obs-gstreamer
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  })
]
