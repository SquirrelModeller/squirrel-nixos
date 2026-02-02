{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    extensions = with pkgs.vscode-extensions; [
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
  };

  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
  ];

  programs.bash.enable = true;
  programs.zsh.enable = true;
}
