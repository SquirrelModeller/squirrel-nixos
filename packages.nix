{
  config,
  pkgs,
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
