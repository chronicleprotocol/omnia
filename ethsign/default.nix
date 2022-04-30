{ lib, buildGoModule }:

buildGoModule rec {
  name = "ethsign-${version}";
  version = "0.17.1";

  src = ./.;

  vendorSha256 = "13n6ymfri3gml2r207567xaq6xqbhcgc13lv04gy0wznjfsfmphp";

  meta = {
    homepage = http://github.com/dapphub/dapptools;
    description = "Make raw signed Ethereum transactions";
    license = [lib.licenses.agpl3];
  };
}
