{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    nh
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
