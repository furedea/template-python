{
  fetchurl,
  mailcap,
  python314,
}:

# TODO: Drop this and use pkgs.python314 once the nixpkgs input has >= 3.14.9.
# 3.14.9 replaces the compromised emSign root in the bundled pip/certifi CA store.
# nixpkgs' mimetypes patch no longer applies to 3.14.9's `knownfiles`, so the same
# substitution is done in postPatch instead.
(python314.override { mimetypesSupport = false; }).overrideAttrs (previousAttrs: rec {
  version = "3.14.9";
  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    hash = "sha256-4C2awhzr2m5GQ1NpdEqSxlzHzYZpaXaUEiz5f/rNHlM=";
  };

  postPatch = (previousAttrs.postPatch or "") + ''
    substituteInPlace Lib/mimetypes.py \
      --replace-fail '"/etc/mime.types",' '"${mailcap}/etc/mime.types",'
  '';
})
