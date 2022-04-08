# Omnia

[![Omnia Tests](https://github.com/chronicleprotocol/omnia/actions/workflows/test.yml/badge.svg)](https://github.com/chronicleprotocol/omnia/actions/workflows/test.yml)
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

For E2E tests you need Docker to be installed and some basic predefined tools.
We use `smocker` for mocking Exchange API requests/responses and local `geth` for omnia relayer tests.
To setup environment you can use this command:

```bash
$ docker-compose -f .github/docker-compose-e2e-tests.yml run omnia_e2e 
```

### E2E Tests Development

For tests development process we created additional image `omnia_e2e_dev`.

Run it:

```bash
$ docker-compose -f .github/docker-compose-e2e-tests.yml run --rm omnia_e2e_dev
```

It will start `bash` session inside omnia dev container with mounted folders.
From here you might run E2E tests using command: 

```bash
$ go test -v -p 1 -parallel 1 -cpu 1 ./...
```

