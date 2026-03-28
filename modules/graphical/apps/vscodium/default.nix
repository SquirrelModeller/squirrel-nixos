{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    qt6.qtdeclarative
    (pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide

        ms-python.python
        ms-python.black-formatter

        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers

        mkhl.direnv
        eamodio.gitlens
        yzhang.markdown-all-in-one
        usernamehw.errorlens
        tomoki1207.pdf

        svelte.svelte-vscode
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
      ];
    })
  ];

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    bash.enable = true;
    zsh.enable = true;
  };
}
