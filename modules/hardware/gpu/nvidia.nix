{lib, ...}: {
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics = {
    enable = true;
  };
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
    ];
}
