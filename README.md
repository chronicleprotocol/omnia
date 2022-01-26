# Omnia

[![Omnia Unit Tests](https://github.com/chronicleprotocol/omnia/actions/workflows/unit_test.yml/badge.svg)](https://github.com/chronicleprotocol/omnia/actions/workflows/unit_test.yml)
[![Build & Push Docker Image](https://github.com/chronicleprotocol/omnia/actions/workflows/docker.yml/badge.svg)](https://github.com/chronicleprotocol/omnia/actions/workflows/docker.yml)

For more information see: https://github.com/makerdao/oracles-v2

## Working with Docker

We introduced Docker environment for local omnia development.

Please follow several steps to build and run it.

#### Building omnia image

NOTE: You have to build it from repo root.

```bash
$ docker build -t omnia -f docker/omnia/Dockerfile .
```

Running omnia with your local environment:

```bash
$ doc run -it --rm -v "$(pwd)"/lib:/home/omnia/lib -v "$(pwd)"/test:/home/omnia/test omnia /bin/bash
```

It will start bash session into docker comtainer with mounted `lib` and `test` folders.

To run `omnia` in container from prev command you can use `omnia` command:

```bash
$ omnia
Importing configuration from /home/omnia/config/feed.json...
```

## SSB Image requirements

`node:lts-alpine` has some major changes and now it does not include `python` and `make` anymore.
So we will have to rework SSB images.

For now it requires special Docker `node` base image.
So before building this image run command:

```bash
$ doc pull node:lts-alpine3.14@sha256:366c71eebb0da62a832729de2ffc974987b5b00ab25ed6a5bd8d707219b65de4
```

## Docker compose
For even more easy development we providing you with `docker-compose.yml` file that will help to set everything up for you.

Right now it contains `omnia_feed` container. 
It contains working feed configuration + spire integration.

And `spire` container with configured spire agent that will be called from `omnia_feed`.

**Where to take `chroniclelabs/spire:latest` image ?**
For now you have to build it manually from [Oracle Suite](https://github.com/makerdao/oracle-suite) repo.
Command for building image:

```bash
$ docker build -t chroniclelabs/spire:latest -f Dockerfile-spire .
```

Example of usage: 

1. Starting Spire Agent

```bash
$ docker-compose up -d spire
```

2. Running omnia with bash:

```bash
$ docker-compose run --rm omnia_feed /bin/bash
```

## Running Unit Tests

For simplicity we create unit tests runner inside docker container. 
So to run unit tests in fresh environment you can use this command: 

```bash
$ docker-compose -f .github/docker-compose-unit-tests.yml run --rm omnia_unit_tests
```

It will create fresh omnia container, mount all your local sources and run tests from `test/units` folder.
Example output: 

```bash
Creating github_omnia_unit_tests_run ... done
======================================
Running: /home/omnia/test/units/config.sh
======================================
TAP version 13
1..10
ok 1 - importGasPrice should correctly parse values > run importGasPrice {"from":"0x","keystore":"","password":"","network":"mainnet","gasPrice":{"source":"node","multiplier":1,"priority":"fast"}}
ok 2 - ETH_GAS_SOURCE should have value: ethgasstation > match ^node
ok 3 - ETH_MAXPRICE_MULTIPLIER should have value: 1 > match ^1$
ok 4 - ETH_TIP_MULTIPLIER should have value: 1 > match ^1$
ok 5 - ETH_GAS_PRIORITY should have value: slow > match ^fast
...
```

### Running E2E Tests

For running E2E tests we need whole environment up and running, so Docker is your choise:
Our Dev/Test environment is described in `docker-compose.yml` file.
Our E2E Tests runners are into `.github/docker-compose-e2e-tests.yml` file.

To run everything as one command you can use:

```bash
$ docker-compose -f docker-compose.yml -f .github/docker-compose-e2e-tests.yml run --rm omnia_e2e_tests
```

NOTE: to be able to operate correctly we have to wait env to be started, so we added initial 61 seconds delay before running tests. 
Example output will be:

```bash
Creating spire_relay.local  ... done
Creating geth.local        ... done
Creating spire_feed.local  ... done
Creating omnia_omnia_feed_1  ... done
Creating omnia_omnia_relay_1 ... done
Creating omnia_omnia_e2e_tests_run ... done
======================================
Starting E2E Omnia tests
Start delay: 61 seconds
======================================
======================================
Running E2E: /home/omnia/test/e2e/omnia_feed_spire.sh
======================================
TAP version 13
ok 1 - run > run_json spire pull -c /home/omnia/spire.json price BTCUSD 0xfadad77b3a7e5a84a1f7ded081e785585d4ffaf3
ok 2 - price.wat is equal to BTCUSD > json .price.wat
1..2
# Success, ran 2 tests!
```

If you have whole your env up and running for some time you don't need to wait initial timeout and you can set `E2E_START_DELAY=0` env variable for `omnia_e2e_tests` using `-e KEY=VAL` property.

Let's say you have your environment up and running: 

```bash
$ docker-compose up -d
```

Now you can run E2E tests container without waiting

```bash
$ docker-compose -f docker-compose.yml -f .github/docker-compose-e2e-tests.yml run -e E2E_START_DELAY=0 --rm omnia_e2e_tests

Creating omnia_omnia_e2e_tests_run ... done
======================================
Starting E2E Omnia tests
Start delay: 0 seconds
======================================
======================================
Running E2E: /home/omnia/test/e2e/omnia_feed_spire.sh
======================================
TAP version 13
ok 1 - run > run_json spire pull -c /home/omnia/spire.json price BTCUSD 0xfadad77b3a7e5a84a1f7ded081e785585d4ffaf3
ok 2 - price.wat is equal to BTCUSD > json .price.wat
1..2
# Success, ran 2 tests!
```

NOTE: You will have to stop your local environment after tests runing:

```bash
$ docker-compose stop
```
