{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "systeminfo-cpu-ram-stats";
  version = "1.0";

  src = ./src;

  nativeBuildInputs = [pkgs.gcc];

  buildPhase = ''
    g++ -o systeminfo-cpu-ram-stats systeminfo.cpp
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp systeminfo-cpu-ram-stats $out/bin/
  '';
}
