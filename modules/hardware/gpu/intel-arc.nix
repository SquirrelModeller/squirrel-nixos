{pkgs, ...}: {
  config = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        intel-compute-runtime
        level-zero
      ];
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      vulkan-loader
      intel-gpu-tools
      libva-utils
    ];

    environment.variables.LIBVA_DRIVER_NAME = "iHD";
  };
}
