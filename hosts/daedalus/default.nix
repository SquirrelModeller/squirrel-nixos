{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.squirrel = ../../homes;
    extraSpecialArgs = {inherit inputs;};
  };
}
