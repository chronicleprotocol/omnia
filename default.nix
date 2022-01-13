{ stdenv, makeWrapper, symlinkJoin, lib, glibcLocales, coreutils, bash, parallel, bc, jq, gnused, datamash, gnugrep, curl
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
    find ./test -name '*_test*' -or -path "*/test/*.sh" -executable | while read -r x; do
      patchShebangs "$x"
      PATH="./exec:$PATH" $x
    done
  '';

  installPhase = let
    path = lib.makeBinPath passthru.runtimeDeps;
    locales = lib.optionalString (glibcLocales != null) ''--set LOCALE_ARCHIVE "${glibcLocales}"/lib/locale/locale-archive'';
  in ''
    mkdir -p $out

    cp -r ./version $out/version
    cp -r ./lib $out/lib

    cp -r ./bin $out/bin
    chmod +x $out/bin/*
    find $out/bin -type f | while read -r x; do
      wrapProgram "$x" \
        --prefix PATH : "$out/exec:${path}" \
        ${locales}
    done

    cp -r ./exec $out/exec
    chmod +x $out/exec/*
    find $out/exec -type f | while read -r x; do
      wrapProgram "$x" \
        --prefix PATH : "$out/exec:${path}" \
        ${locales}
    done
  '';

  meta = {
    description = "Omnia is a Feed and Relay Oracle client";
    homepage = "https://github.com/chronicleprotocol/omnia";
    license = lib.licenses.gpl3;
    inherit version;
  };
}
