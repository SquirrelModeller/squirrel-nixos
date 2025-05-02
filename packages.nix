{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tree
    ranger
    inputs.alejandra.defaultPackage.${pkgs.system}
  ];
}
