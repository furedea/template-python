{
  fetchurl,
  lib,
  stdenvNoCC,
  versionCheckHook,
}:

# TODO: Drop this and use pkgs.uv once the nixpkgs input has >= 0.13.5.
# Official build of uv 0.13.5. 0.13.4 drops the compromised emSign root from its bundled CA store,
# and 0.13.6 is the first release that can install managed CPython 3.15.2 (the devShell uses nixpkgs' Python instead).
let
  # Hashes are the sha256 digests that GitHub reports for each release asset.
  assets = {
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-dD+FA1oZluyzUGWeAc2frqlwmCm+CbG0sDxz6vPJzXM=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-V++dnMsB+xvZmN+ZWw3SIbUvfXhB++qT8tRGO/Yft6k=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "uv";
  version = "0.13.5";

  src = fetchurl {
    url = "https://github.com/astral-sh/uv/releases/download/${finalAttrs.version}/uv-${asset.target}.tar.gz";
    inherit (asset) hash;
  };

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 -t "$out/bin" uv uvx
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Python package and project manager, official binary build";
    homepage = "https://github.com/astral-sh/uv";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "uv";
    platforms = builtins.attrNames assets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
