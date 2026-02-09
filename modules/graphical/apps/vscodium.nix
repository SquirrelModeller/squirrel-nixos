{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    qt6.qtdeclarative
    (pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;

      vscodeExtensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide

        ms-python.python

        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers

        mkhl.direnv
        eamodio.gitlens
        yzhang.markdown-all-in-one
        usernamehw.errorlens
        tomoki1207.pdf
      ];
    })
  ];

  programs.bash.enable = true;
  programs.zsh.enable = true;
}
