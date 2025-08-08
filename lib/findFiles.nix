#### CREDITS ####
# Written by Jet/Michael-C-Buckley
# https://github.com/Michael-C-Buckley/nixos/blob/master/flake/configurations/user/michael/default.nix
#################
# Auto-detect and return a link-ready attrset of files
# It will link them in the same format in which they are created
{ lib, ... }:
let
  inherit (builtins) toString;
  inherit (lib.attrsets) listToAttrs;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.lists) map;
  inherit (lib.strings) removePrefix;
  findFiles = directory:
    let
      directoryPrefix = (toString directory) + "/";
    in
    if builtins.pathExists directory
    then
      listToAttrs
        (map
          (filepath: {
            name = removePrefix directoryPrefix (toString filepath);
            value.source = filepath;
          })
          (listFilesRecursive directory))
    else { };
in
findFiles
