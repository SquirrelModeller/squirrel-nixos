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
          ./modules/users/nixos.nix
          (./hosts + "/${hostName}/configuration.nix")
          inputs.hjem.nixosModules.default
          inputs.agenix.nixosModules.default
          inputs.rrss.nixosModules.rrss
          inputs.diaspora.nixosModules.diaspora
          inputs.domacroc.nixosModules.default

          {
            hjem.extraModules = [inputs.zesis.hjemModules.default];
            environment.systemPackages = [
              inputs.agenix.packages.${system}.default
            ];
          }
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
          ./modules/users/darwin.nix
          (./hosts + "/${hostName}/configuration.nix")
          inputs.hjem.darwinModules.default
          inputs.agenix.darwinModules.default

          {
            environment.systemPackages = [
              inputs.agenix.packages.${system}.default
            ];
          }
        ];
      };
  in {
    nixosConfigurations = lib.genAttrs linuxHosts makeNixosConfiguration;
    darwinConfigurations = lib.genAttrs darwinHosts makeDarwinConfiguration;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-qtpin.url = "github:nixos/nixpkgs/a799d3e3886da994fa307f817a6bc705ae538eeb";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
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
    domacroc = {
      url = "github:SquirrelModeller/domacroc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    squirrel-website = {
      url = "github:SquirrelModeller/squirrel-website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rrss = {
      url = "github:SquirrelModeller/rrss";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    diaspora = {
      url = "github:zesis-shell/diaspora";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zesis = {
      url = "github:zesis-shell/zesis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
