{
  description = "Squirrel OS";

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    vscodiumOverlay = prev: {
      vscodium = prev.vscodium.overrideAttrs (
        let
          version = "1.109.51242";
        in {
          inherit version;

          src = prev.fetchurl {
            url = "https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-darwin-arm64-${version}.zip";
            hash = "sha256-zFRvn9BT5xx+HMWhnI5APKUDekOvZjzbN3SlqtdMBOE=";
          };
        }
      );
    };

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
          inputs.agenix.nixosModules.default
          inputs.rrss.nixosModules.rrss

          {
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
          ./modules/options
          ./modules/users/darwin.nix
          (./hosts + "/${hostName}/configuration.nix")
          inputs.hjem.darwinModules.default
          inputs.agenix.darwinModules.default

          {
            nixpkgs.overlays = [vscodiumOverlay];

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
    squirrel-website = {
      url = "github:SquirrelModeller/squirrel-website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rrss = {
      url = "github:SquirrelModeller/rrss";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
