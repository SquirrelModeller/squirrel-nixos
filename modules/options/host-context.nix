{lib, ...}: {
  options.squirrelOS.host = {
    roles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    capabilities = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
      # I added battery as an example for system-wide options
      default = {
        graphical = false;
        battery = false;
      };
    };
  };
}
