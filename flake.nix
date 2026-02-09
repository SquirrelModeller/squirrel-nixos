{
  description = "Squirrel OS";

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    systems,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;

    hostEntries = builtins.readDir ./hosts;
    hostNames = builtins.filter (
      h:
        builtins.pathExists (./hosts + "/${h}") && builtins.readFileType (./hosts + "/${h}") == "directory"
    ) (builtins.attrNames hostEntries);

    userEntries = builtins.readDir ./users;
    userNames = builtins.filter (
      u:
        builtins.pathExists (./users + "/${u}")
        && builtins.readFileType (./users + "/${u}") == "directory"
        && builtins.pathExists (./users + "/${u}/programs/default.nix")
    ) (builtins.attrNames userEntries);

    getUserPrograms = pkgs: inputs: username: let
      programsFile = ./users + "/${username}/programs/default.nix";
    in
      import programsFile {
        inherit pkgs inputs;
        lib = pkgs.lib;
      };

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
          inherit inputs self getUserPrograms;
          availableUsers = userNames;
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
            getUserPrograms
            nix-darwin
            ;
          availableUsers = userNames;
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
    domacro = {
      url = "github:SquirrelModeller/domacroc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
