{ pkgs, inputs, lib, colors, ... }:
let
  treeSitterParsers = grammars: [
    grammars."tree-sitter-bash"
    grammars."tree-sitter-c"
    grammars."tree-sitter-cpp"
    grammars."tree-sitter-css"
    grammars."tree-sitter-html"
    grammars."tree-sitter-javascript"
    grammars."tree-sitter-json"
    grammars."tree-sitter-python"
    grammars."tree-sitter-rust"
    grammars."tree-sitter-tsx"
    grammars."tree-sitter-typescript"
    grammars."tree-sitter-nix"
    inputs.nix-qml-support.packages.${pkgs.stdenv.system}.tree-sitter-qmljs
  ];

  devTools = [
    pkgs.clang-tools
    pkgs.rust-analyzer
    pkgs.nil
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.bash-language-server
    pkgs.nodePackages.vscode-langservers-extracted
    pkgs.qt6.qtdeclarative
  ];

  customEmacs =
    (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs:
      let p = epkgs; in [
        p."use-package"
        p."format-all"
        p."all-the-icons"
        p."nix-mode"
        p.dashboard
        p.elscreen
        p.flycheck
        p.workgroups2
        p."rainbow-mode"
        p."multiple-cursors"
        p.company
        p.neotree
        p.minimap
        p.org
        p."org-bullets"
        p."org-modern"
        p."org-present"
        p."ox-reveal"
        p.htmlize
        p."lsp-mode"
        p."lsp-ui"
        p."lsp-pyright"
        p."which-key"
        p."company-box"
        p."markdown-mode"
        p."markdown-preview-mode"
        p."markdown-toc"
        p.direnv
        (p.treesit-grammars.with-grammars (grammars: treeSitterParsers grammars))
        inputs.nix-qml-support.packages.${pkgs.stdenv.system}."qml-ts-mode"
      ]
    );

  emacsInitDir = pkgs.stdenv.mkDerivation {
    pname = "emacs-init-squirrel";
    version = "1";
    src = ./emacs;
    nativeBuildInputs = [ customEmacs pkgs.coreutils ];
    installPhase = ''
      mkdir -p $out
      cp -r ./* $out/
      ${customEmacs}/bin/emacs --batch \
        --eval "(require 'org)" \
        --eval "(org-babel-tangle-file \"$out/config.org\" \"$out/config.el\")"
    '';
  };

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
[
  # TODO: Fix emacs temp file folder source
  emacsWrapped
  pkgs.hyprpaper
  pkgs.htop
  pkgs.grim
  pkgs.slurp
  pkgs.wl-clipboard
  pkgs.fastfetch
  pkgs.socat
  pkgs.nixpkgs-fmt
  pkgs.vlc
  pkgs.playerctl
  pkgs.pandoc
  pkgs.kitty
  inputs.quickshell.packages.${pkgs.system}.default
  inputs.alejandra.defaultPackage.${pkgs.system}
  pkgs.hyprpaper
  pkgs.blender-hip
  pkgs.tofi
  pkgs.tree
  pkgs.ranger
  pkgs.wallust
  pkgs.comma

  (pkgs.wrapOBS {
    plugins = [
      pkgs.obs-studio-plugins.wlrobs
      pkgs.obs-studio-plugins."obs-gstreamer"
      pkgs.obs-studio-plugins."obs-pipewire-audio-capture"
      pkgs.obs-studio-plugins."obs-vkcapture"
    ];
  })
]
