{ lib, buildGoModule }:

buildGoModule rec {
  name = "ethsign-${version}";
  version = "0.17.1";

  src = ./.;

  vendorSha256 = "0rymqf8bdpx68ds58xhxsm2pffmf3ncbfzzp3yyb1xn3cxy1ck64";

  meta = {
    homepage = http://github.com/dapphub/dapptools;
    description = "Make raw signed Ethereum transactions";
    license = [lib.licenses.agpl3];
  };
}
