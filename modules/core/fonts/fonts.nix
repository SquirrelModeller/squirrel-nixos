{
  pkgs,
  lib,
  ...
}: {
  fonts = {
    enableDefaultPackages = false;

    fontconfig = {
      enable = true;
      hinting.enable = true;
      antialias = true;
      defaultFonts = {
        monospace = ["JetBrains Mono" "Noto Sans CJK JP"];
        sansSerif = ["Noto Sans CJK JP"];
        serif = ["Noto Serif CJK JP"];
      };
    };

    fontDir = {
      enable = true;
      decompressFonts = true;
    };

    packages = with pkgs; [
      nerd-fonts.terminess-ttf
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      jetbrains-mono
      noto-fonts-cjk-sans
    ];
  };
}
