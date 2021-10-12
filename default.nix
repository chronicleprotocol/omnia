{ stdenv, makeWrapper, runCommand, lib, glibcLocales, coreutils, bash, parallel, bc, jq, gnused, datamash, gnugrep, curl
, ethsign, seth, setzer-mcd, stark-cli
, ssb-server, oracle-suite }:

stdenv.mkDerivation rec {
  name = "omnia-${version}";
  version = lib.fileContents ./version;
  src = ./.;

  buildInputs = [ coreutils bash parallel bc jq gnused datamash gnugrep ssb-server ethsign seth setzer-mcd stark-cli oracle-suite curl ];
  nativeBuildInputs = [ makeWrapper ];
  passthru.runtimeDeps = buildInputs;

  buildPhase = ''
    find ./bin -type f | while read -r x; do patchShebangs "$x"; done
    find ./exec -type f | while read -r x; do patchShebangs "$x"; done
  '';

  doCheck = true;
  checkPhase = ''
    find . -name '*_test*' -or -path "*/test/*.sh" | while read -r x; do
      patchShebangs "$x"; $x
    done
  '';

  installPhase = let
    path = lib.makeBinPath passthru.runtimeDeps;
    locales = lib.optionalString (glibcLocales != null) ''--set LOCALE_ARCHIVE "${glibcLocales}"/lib/locale/locale-archive'';
  in ''
    mkdir -p $out

    cp -r ./lib $out/lib
    chmod +x $out/lib/omnia.sh

    cp -r ./bin $out/bin
    chmod +x $out/bin/*

    find $out/bin -type f | while read -r x; do
      wrapProgram "$x" \
        --prefix PATH : "$out/bin:${path}" \
        ${locales}
    done
  '';

  meta = with lib; {
    description = "Omnia is a Feed and Relay Oracle client";
    homepage = "https://github.com/chronicleprotocol/omnia";
    license = licenses.gpl3;
    inherit version;
  };
}