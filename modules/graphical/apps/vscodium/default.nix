{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nil
    nixpkgs-fmt
    qt6.qtdeclarative
    vscodium
  ];
}
