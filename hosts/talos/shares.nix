{ pkgs, ... }:

let
  d = path: mode: user: group: "d ${path} ${mode} ${user} ${group} - -";
in
{
  users.groups = {
    media = { };
  };

  environment.systemPackages = [ pkgs.acl ];

  systemd.tmpfiles.rules = [
    (d "/talos" "0755" "root" "root")
    (d "/talos/media" "2775" "root" "media")
    (d "/talos/services" "0755" "root" "root")
    (d "/talos/shared" "2775" "root" "media")
    (d "/talos/users" "0711" "root" "root")

    (d "/talos/media/movies" "2775" "root" "media")
    (d "/talos/media/music" "2775" "root" "media")
    (d "/talos/media/photos" "2775" "root" "media")
    (d "/talos/media/shows" "2775" "root" "media")

    (d "/talos/media/testfolder" "2775" "root" "root")
  ];
}
