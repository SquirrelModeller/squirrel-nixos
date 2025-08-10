{ pkgs, ... }:
# This is the common packages most systems need.
# TODO: Make pkg groups
{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
