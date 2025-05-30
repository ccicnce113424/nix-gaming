{
  lib,
  stdenvNoCC,
  fetchzip,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "proton-cachyos-bin";
    inherit (info) version;

    src = fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/${finalAttrs.version}/proton-${finalAttrs.version}-x86_64_v3.tar.xz";
      inherit (info) hash;
    };

    outputs = [
      "out"
      "steamcompattool"
    ];

    buildCommand = ''
      runHook preBuild

      echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

      ln -s $src $steamcompattool

      runHook postBuild
    '';

    meta = {
      description = ''
        Compatibility tool for Steam Play based on Wine and additional components.

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/CachyOS/proton-cachyos";
      license = lib.licenses.gpl3Plus;
      platforms = ["x86_64-linux"];
      passthru.updateScript = ./update.sh;
    };
  })
