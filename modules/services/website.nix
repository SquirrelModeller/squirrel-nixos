{
  inputs,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts.":3975".extraConfig = ''
      root * ${inputs.squirrel-website.packages.${pkgs.system}.default}
      file_server
    '';
  };

  networking.firewall.allowedTCPPorts = [3975];
}
