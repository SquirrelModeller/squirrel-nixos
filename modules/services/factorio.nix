{pkgs, ...}: {
  services.factorio = {
    enable = true;
    openFirewall = false;
    game-name = "Talos Spaghetti Industries";
    description = "Industrial catastrophe simulator";
    public = false;
    lan = true;
    requireUserVerification = false;

    game-password = "itisjustastarterbasetrustmebro";

    saveName = "idiotsLLC";

    admins = [
      "Wabar"
    ];

    package = pkgs.factorio-headless.overrideAttrs (_old: rec {
      version = "2.1.23";
      src = pkgs.fetchurl {
        url = "https://factorio.com/get-download/${version}/headless/linux64";
        name = "factorio-headless-${version}.tar.xz";
        hash = "sha256-RjMlD3dHZ2J5+yEKFxe6NMrta5iQyVH7Pkae7+Q8Rrk=";
      };
    });
  };

  systemd.services.factorio.serviceConfig = {
    LockPersonality = true;
    SystemCallArchitectures = "native";
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    InaccessiblePaths = [
      "/talos/users"
      "/talos/shared"
      "/talos/services"
      "/boot"
      "/root"
    ];
  };

  networking.firewall.interfaces."lan0".allowedUDPPorts = [34197];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkg.pname or pkg.name) ["factorio-headless"];
}
