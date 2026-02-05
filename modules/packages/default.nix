{ pkgs, lib, ... }:
let
  #isLinux = ctx.platform.isLinux or false;
in
{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];
  #   ++ lib.optionals isLinux[ 
  #   cifs-utils
  # ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
