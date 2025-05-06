{ config
, lib
, pkgs
, inputs
, modulesPath
, ...
}:
let
  gpuIds = [
    "1002:744c"
    "1002:ab30"
  ];
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./networking.nix
    ./fs
    inputs.home-manager.nixosModules.home-manager
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules =
      [ "kvm-amd" ] ++
      (if config.modules.system.virtualisation.enable then
        [ "vfio_pci" ]
      else
        [ "amdgpu" ]);
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ] ++ lib.optionals config.modules.system.virtualisation.enable [
      "vfio-pci.ids=${lib.concatStringsSep "," gpuIds}"
      "video=efifb:off"
    ];
    extraModprobeConfig = lib.mkIf config.modules.system.virtualisation.enable ''
      options vfio-pci ids=${lib.concatStringsSep "," gpuIds}
      options vfio_iommu_type1 allow_unsafe_interrupts=1
    '';
    extraModulePackages = [ ];
  };


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  environment.systemPackages = lib.mkIf (!config.modules.system.virtualisation.enable) (with pkgs; [
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    libva
    vaapiVdpau
    libvdpau-va-gl
  ]);

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.squirrel = ../../homes;
    extraSpecialArgs = { inherit inputs; };
  };
}
