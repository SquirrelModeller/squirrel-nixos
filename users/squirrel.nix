{ config
, pkgs
, ...
}: {
  users.users.squirrel = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "kvm" ];
    shell = pkgs.bash;
    home = "/home/squirrel";
  };
}
