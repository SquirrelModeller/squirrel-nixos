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
  ];
}
