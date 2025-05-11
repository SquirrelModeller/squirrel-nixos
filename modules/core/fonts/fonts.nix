{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig = {
      enable = true;
      hinting.enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [
          "JetBrains Mono"
          "Noto Sans"
          "Unifont"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK JP"
          "Unifont"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif CJK JP"
          "Unifont"
        ];
      };
    };
    fontDir = {
      enable = true;
      decompressFonts = true;
    };
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      noto-fonts-extra
      unifont
      nerd-fonts.hack
    ];
  };
}
