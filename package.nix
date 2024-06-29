{ lib
, pkgs
, stdenv
, scons
, godot-cpp
, withPlatform ? "linux"
, withTarget ? "template_release"
}:

let
  mkSconsFlagsFromAttrSet = lib.mapAttrsToList (k: v:
    if builtins.isString v
    then "${k}=${v}"
    else "${k}=${builtins.toJSON v}");
in
stdenv.mkDerivation {
  name = "godot-extension-dbus-nodes";
  src = ./.;

  nativeBuildInputs = with pkgs; [ scons pkg-config makeWrapper ];
  buildInputs = with pkgs; [ systemd godot-cpp ];
  enableParallelBuilding = true;
  BUILD_NAME = "nix-flake";

  sconsFlags = mkSconsFlagsFromAttrSet {
    platform = withPlatform;
    target = withTarget;
  };

  outputs = [ "out" ];

  preBuild = ''
    substituteInPlace SConstruct \
    --replace-fail 'godot-cpp/SConstruct' '${godot-cpp}/SConstruct'
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp project/addons/godot_dbus/bin/*.so $out/bin/
    cp project/addons/godot_dbus/godot_dbus.gdextension $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/mindwm/gdextension-dbus-nodes";
    description = "Godot 4 GDExtension adding a simple DBusClient and DBusServer";
    license = licenses.lgpl3;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ omgbebebe ];
  };
}
