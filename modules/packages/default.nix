{ pkgs, lib, ... }:
# This is the common packages most systems need.
# TODO: Make pkg groups
{
  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      git
      vim
      wget
      cifs-utils;
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
