{
  description = "Squirrel OS";
  outputs = { self, nixpkgs, systems, ... }@inputs:
    let
      hostEntries = builtins.readDir ./hosts;
      hostNames = builtins.filter
        (h: builtins.pathExists (./hosts + "/${h}") &&
          builtins.readFileType (./hosts + "/${h}") == "directory")
        (builtins.attrNames hostEntries);
      hostModules = builtins.listToAttrs (map
        (hn: {
          name = hn;
          value = ./hosts + "/${hn}/configuration.nix";
        })
        hostNames);

      userEntries = builtins.readDir ./users;
      userNames = builtins.filter
        (u: builtins.pathExists (./users + "/${u}") &&
          builtins.readFileType (./users + "/${u}") == "directory" &&
          builtins.pathExists (./users + "/${u}/programs/default.nix"))
        (builtins.attrNames userEntries);

      getUserPrograms = pkgs: inputs: username:
        let programsFile = ./users + "/${username}/programs/default.nix";
        in import programsFile { inherit pkgs inputs; lib = pkgs.lib; };

      makeNixosConfiguration = hostName: configPath:
        let
          hostPath = ./hosts/${hostName};
          systemFile = hostPath + "/system";
          system =
            if builtins.pathExists systemFile
            then builtins.readFile systemFile
            else "x86_64-linux";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs self;
            availableUsers = userNames;
            getUserPrograms = getUserPrograms;
            hostName = hostName;
            hostSystem = system;
          };
          modules = [
            ./modules/options
            ./modules/users.nix
            ./hosts
            configPath
            inputs.hjem.nixosModules.default
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs makeNixosConfiguration hostModules;
    };
  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-qml-support = {
      url = "git+https://git.outfoxxed.me/outfoxxed/nix-qml-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
