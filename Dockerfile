FROM golang:1.17-alpine3.15 as go-builder
RUN apk --no-cache add git
ARG CGO_ENABLED=0

ARG DAPP_BRANCH="master"

WORKDIR /go/src/dapptools
RUN git clone --depth 1 --branch ${DAPP_BRANCH} https://github.com/dapphub/dapptools.git .

WORKDIR /go/src/dapptools/src/ethsign
RUN go mod tidy && \
  go mod download && \
  go build .

ARG ORACLE_SUITE_BRANCH="v0.3.5"

WORKDIR /go/src/oracle-suite
RUN git clone --depth 1 --branch ${ORACLE_SUITE_BRANCH} https://github.com/chronicleprotocol/oracle-suite.git .

RUN go mod tidy && \
  go mod download && \
  go build ./cmd/spire && \
  go build ./cmd/gofer && \
  go build ./cmd/ssb-rpc-client

#FROM python:3.10.2-alpine3.15 # failing `test -x FILE`
#FROM python:3.9.10-alpine3.14 # same
FROM python:3.9.9-alpine3.15

RUN apk add --update --no-cache \
  jq curl git make perl g++ ca-certificates parallel tree \
  bash bash-doc bash-completion \
  util-linux pciutils usbutils coreutils binutils findutils grep iproute2 \
  nodejs \
  && apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
  jshon agrep datamash

COPY --from=go-builder /go/src/dapptools/src/dapp/ /opt/dapp/
COPY --from=go-builder /go/src/dapptools/src/seth/ /opt/seth/

ARG SETZER_BRANCH="v0.4.0"
RUN git clone --depth 1 --branch ${SETZER_BRANCH} https://github.com/makerdao/setzer-mcd.git \
  && cp -R setzer-mcd /opt/setzer \
  && rm -rf setzer-mcd

COPY --from=go-builder \
  /go/src/dapptools/src/ethsign/ethsign \
  /go/src/oracle-suite/spire \
  /go/src/oracle-suite/gofer \
  /go/src/oracle-suite/ssb-rpc-client \
  /usr/local/bin/
COPY ./docker/geth/bin/hevm-0.48.1 /usr/local/bin/hevm
COPY ./docker/geth/bin/solc-0.5.12 /usr/local/bin/solc
RUN pip install --no-cache-dir mpmath sympy ecdsa==0.16.0
COPY ./docker/starkware/ /opt/starkware/
COPY ./bin /opt/omnia/bin/
COPY ./exec /opt/omnia/exec/
COPY ./lib /opt/omnia/lib/
COPY ./version /opt/omnia/version

ENV HOME=/home/omnia

ENV OMNIA_CONFIG ${HOME}/omnia.json \
  SPIRE_CONFIG ${HOME}/spire.json \
  GOFER_CONFIG ${HOME}/gofer.json \
  ETH_RPC_URL=http://geth.local:8545 \
  ETH_GAS=7000000 \
  CHLORIDE_JS='1'

COPY ./config/feed.json ${OMNIA_CONFIG}
COPY ./docker/spire/config/client_feed.json ${SPIRE_CONFIG}
COPY ./docker/gofer/client.json ${GOFER_CONFIG}
WORKDIR ${HOME}
COPY ./docker/keystore/ .ethereum/keystore/
COPY ./docker/ssb-server/config/manifest.json .ssb/manifest.json
COPY ./docker/ssb-server/config/secret .ssb/secret
COPY ./docker/ssb-server/config/config.json .ssb/config
ARG USER=1000
ARG GROUP=1000
RUN chown -R ${USER}:${GROUP} ${HOME}
USER ${USER}:${GROUP}
RUN printf 'will cite' | parallel --citation 1>/dev/null 2>/dev/null; exit 0
# Setting up PATH for seth, setzer and omnia bin folder
# Here we have set of different pathes included:
# - /opt/dapp - For `dapp` executable
# - /opt/seth - For `seth` executable
# - /opt/setzer - For `setzer` executable
# - /opt/starkware - For Starkware python dependency
# - /opt/omnia/bin - Omnia executables
# - /opt/omnia/exec - Omnia transports executables
ENV PATH="/opt/dapp/bin:/opt/seth/bin:/opt/setzer/bin:/opt/starkware:/opt/omnia/bin:/opt/omnia/exec:${PATH}"
CMD ["omnia"]