{pkgs, ...}: let
  squirrelWebsite = pkgs.stdenv.mkDerivation {
    pname = "squirrel-website";
    version = "1.0.0";

    src = "https://github.com/SquirrelModeller/squirrel-nixos.git";

    nativeBuildInputs = with pkgs; [
      nodejs
      pnpm
    ];

    buildPhase = ''
      export HOME=$TMPDIR
      pnpm ci
      pnpm run build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r build/* $out/
    '';
  };
in {
  services.caddy = {
    enable = true;

    virtualHosts.":3975".extraConfig = ''
      root * ${squirrelWebsite}
      file_server
    '';
  };

  networking.firewall.allowedTCPPorts = [3975];
}
