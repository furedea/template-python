{
  fetchurl,
  mailcap,
  python314,
}:

# TODO: Drop this and use pkgs.python314 once the nixpkgs input has >= 3.14.10.
# 3.14.10 is the first release whose `ssl` module denylists the compromised eMudhra intermediates.
# nixpkgs' mimetypes patch no longer applies to 3.14's `knownfiles`, so the same
# substitution is done in postPatch instead.
(python314.override { mimetypesSupport = false; }).overrideAttrs (previousAttrs: rec {
  version = "3.14.10";
  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    hash = "sha256-3kFKVxGavvUnhNiZPjQdU67WNfwrBcJgfZ+YosW3IDI=";
  };

  postPatch = (previousAttrs.postPatch or "") + ''
    substituteInPlace Lib/mimetypes.py \
      --replace-fail '"/etc/mime.types",' '"${mailcap}/etc/mime.types",'
  '';
})
