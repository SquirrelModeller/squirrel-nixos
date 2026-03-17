{pkgs, ...}: {
  services.factorio = {
    enable = true;
    openFirewall = true;
    game-name = "Talos Spaghetti Industries";
    description = "Industrial catastrophe simulator";
    public = false;
    lan = true;
    requireUserVerification = false;

    game-password = "itisjustastarterbasetrustmebro";

    saveName = "spagett";

    admins = [
      "Wabar"
    ];

    package = pkgs.factorio-headless.overrideAttrs (_old: rec {
      version = "2.0.76";
      src = pkgs.fetchurl {
        url = "https://factorio.com/get-download/${version}/headless/linux64";
        name = "factorio-headless-${version}.tar.xz";
        hash = "sha256-7zZj9mFG12NC98CaP3Q3kmNvjNlcOeomz8pb0uDpJDA=";
      };
    });
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkg.pname or pkg.name) ["factorio-headless"];
}
