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

    saveName = "wetestinprod";

    admins = [
      "Wabar"
    ];

    package = pkgs.factorio-headless.overrideAttrs (_old: rec {
      version = "2.1.8";
      src = pkgs.fetchurl {
        url = "https://factorio.com/get-download/${version}/headless/linux64";
        name = "factorio-headless-${version}.tar.xz";
        hash = "sha256-FrEizV9IEYzUS8rx0n/ZM66mC5kCu9Qm/SY1lEB1nxI=";
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
