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

    installPhase = ''
      runHook preInstall

      # Make it impossible to add to an environment. You should use the appropriate NixOS option.
      # Also leave some breadcrumbs in the file.
      echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

      mkdir $steamcompattool
      ln -s $src/* $steamcompattool
      rm $steamcompattool/compatibilitytool.vdf
      cp $src/compatibilitytool.vdf $steamcompattool

      runHook postInstall
    '';

    preFixup = ''
      substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
        --replace-fail "proton-${finalAttrs.version}-x86_64_v3" "Proton-CachyOS"
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
