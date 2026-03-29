{
  config,
  self,
  ...
}: {
  age.secrets.rrss-env = {
    file = "${self}/secrets/rrss-env.age";
    owner = "rrss";
    group = "rrss";
    mode = "0400";
  };
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.rrss = {
    enable = true;
    environmentFile = config.age.secrets.rrss-env.path;
  };
}
