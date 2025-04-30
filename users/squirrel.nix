{
  config,
  pkgs,
  ...
}: {
  users.users.squirrel = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.bash;
    home = "/home/squirrel";
  };
}
