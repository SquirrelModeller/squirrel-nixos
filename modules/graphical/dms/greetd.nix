{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session "
          + "--cmd ${pkgs.uwsm}/bin/uwsm";
        user = "greeter";
      };
    };
  };
}
