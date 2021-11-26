# Building final omnia container
FROM ghcr.io/chronicleprotocol/base:latest

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  datamash parallel py3-pip

WORKDIR /home/omnia

COPY ./docker/starkware /home/omnia/starkware
COPY ./bin /home/omnia/bin/
COPY ./exec /home/omnia/exec/
COPY ./lib /home/omnia/lib/
COPY ./docker/keystore/ /home/omnia/keystore/
COPY ./docker/omnia/config/ /home/omnia/config/
COPY ./version /home/omnia/version
# Copy Spire configuration
COPY ./docker/spire/config/client_feed.json /home/omnia/spire.json

# SSB requirements
COPY docker/ssb-server/config/secret /home/omnia/.ssb/secret
COPY docker/ssb-server/config/manifest.json /home/omnia/.ssb/manifest.json
COPY docker/ssb-server/config/config.json /home/omnia/.ssb/config

# Requirements for starkware
RUN pip install mpmath sympy ecdsa==0.16.0

# Disabling parallel notification
RUN printf 'will cite' | parallel --citation; exit 0

# Setting up PATH for seth, setzer and omnia bin folder
# Here we have set of different pathes included:
# - /home/omnia/setzer - For `setzer` executable
# - /home/omnia/starkware - For Starkware python dependency
# - /home/omnia/bin - Omnia executables
# - /home/omnia/exec - Omnia transports executables
# - /home/omnia/.local/bin - for pip (Python 3) packages required for Starkware
ENV PATH="/home/omnia/starkware:/home/omnia/bin:/home/omnia/exec:/home/omnia/.local/bin:${PATH}"

ENV OMNIA_CONFIG /home/omnia/config/feed.conf
ENV SPIRE_CONFIG /home/omnia/spire.json

# Setting up seth
ENV ETH_RPC_URL=http://geth.local:8545
ENV ETH_GAS=7000000

CMD ["omnia"]