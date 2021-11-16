# Omnia

[![Omnia Unit Tests](https://github.com/chronicleprotocol/omnia/actions/workflows/unit_test.yml/badge.svg)](https://github.com/chronicleprotocol/omnia/actions/workflows/unit_test.yml)

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
Importing configuration from /home/omnia/config/feed.conf...
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
