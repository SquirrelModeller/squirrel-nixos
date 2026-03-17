{
  lib,
  self,
}: let
  findFiles = import ../../lib/findFiles.nix {inherit lib;};

  usersDir = ../../users;
  userEntries = builtins.readDir usersDir;

  availableUsers =
    builtins.filter
    (u:
      userEntries.${u}
      == "directory"
      && builtins.pathExists (usersDir + "/${u}/programs/default.nix"))
    (builtins.attrNames userEntries);

  getUserDotfiles = username: let
    dotfilesDir = usersDir + "/${username}/dotfiles";
  in
    if builtins.pathExists dotfilesDir
    then findFiles dotfilesDir
    else {};

  getUserMisc = username: let
    f = usersDir + "/${username}/misc.nix";
  in
    if builtins.pathExists f
    then import f {}
    else {};

  getUserProgramsPath = username:
    usersDir + "/${username}/programs/default.nix";

  getUserServicesImport = username: let
    f = usersDir + "/${username}/services.nix";
  in
    if builtins.pathExists f
    then f
    else null;
in {
  inherit
    availableUsers
    getUserDotfiles
    getUserMisc
    getUserProgramsPath
    getUserServicesImport
    ;
}
