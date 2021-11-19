#!/bin/bash
test_path=$(cd "${BASH_SOURCE[0]%/*}"; pwd)
root_path=$(cd "$test_path/../.."; pwd)
lib_path="$root_path/lib"
docker_compose_cfg="$root_path/docker-compose.yml"

. "$lib_path/log.sh"

. "$root_path/tap.sh" 2>/dev/null || . "$root_path/test/tap.sh"

assert "run" run_json spire pull -c "$SPIRE_CONFIG" price "BTCUSD" "0xfadad77b3a7e5a84a1f7ded081e785585d4ffaf3"
assert "price.wat is equal to BTCUSD" json '.price.wat' <<< '"BTCUSD"'