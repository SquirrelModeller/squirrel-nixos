{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  # anyio 4.14.2's test suite fails on this nixpkgs (test_tls / test_itertools), and
  # the others only run tests that pull in heavy deps (jupyter, elasticsearch, httpx)
  python312 = pkgs.python312.override {
    packageOverrides = _: prev:
      lib.genAttrs ["anyio" "matrix-nio" "aiohttp-socks" "python-socks"]
      (name: prev.${name}.overridePythonAttrs {doCheck = false;});
  };
in {
  age.secrets.rrss-env = {
    file = "${self}/secrets/rrss-env.age";
    owner = "rrss";
    group = "rrss";
    mode = "0400";
  };
  services.rrss = {
    enable = true;
    package = inputs.rrss.packages.${pkgs.stdenv.hostPlatform.system}.default.override {inherit python312;};
    environmentFile = config.age.secrets.rrss-env.path;
  };
}
