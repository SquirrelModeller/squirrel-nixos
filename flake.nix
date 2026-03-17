{
  description = "Squirrel OS";

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    hostEntries = builtins.readDir ./hosts;
    hostNames = builtins.filter (
      h:
        builtins.pathExists (./hosts + "/${h}") && builtins.readFileType (./hosts + "/${h}") == "directory"
    ) (builtins.attrNames hostEntries);

    getHostSystem = hostName: let
      systemFile = ./hosts/${hostName}/system;
    in
      if builtins.pathExists systemFile
      then lib.strings.trim (builtins.readFile systemFile)
      else "x86_64-linux";

    isDarwinSystem = sys: builtins.match ".*-darwin" sys != null;

    linuxHosts = builtins.filter (hn: !isDarwinSystem (getHostSystem hn)) hostNames;
    darwinHosts = builtins.filter (hn: isDarwinSystem (getHostSystem hn)) hostNames;

    makeNixosConfiguration = hostName: let
      system = getHostSystem hostName;
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs self;
        };
        modules = [
          ./hosts
          ./modules/options
          ./modules/users/nixos.nix
          (./hosts + "/${hostName}/configuration.nix")
          inputs.hjem.nixosModules.default
        ];
      };

    makeDarwinConfiguration = hostName: let
      system = getHostSystem hostName;
    in
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            self
            nix-darwin
            ;
        };
        modules = [
          ./modules/options
          ./modules/users/darwin.nix
          (./hosts + "/${hostName}/configuration.nix")
          inputs.hjem.darwinModules.default
        ];
      };
  in {
    nixosConfigurations = lib.genAttrs linuxHosts makeNixosConfiguration;
    darwinConfigurations = lib.genAttrs darwinHosts makeDarwinConfiguration;
  };

  inputs = {
    systems.url = "github:nix-systems/default-linux";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-qml-support = {
      url = "git+https://git.outfoxxed.me/outfoxxed/nix-qml-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    domacro = {
      url = "github:SquirrelModeller/domacroc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
