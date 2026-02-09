{pkgs, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) ["steam" "steam-unwrapped"];

  programs.steam.enable = true;
}
