{
  pkgs,
  lib,
  ...
}: {
  services.dbus = {
    enable = true;
    packages = lib.attrValues {inherit (pkgs) dconf;};
  };
}
