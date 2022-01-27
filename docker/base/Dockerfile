FROM golang:1.17-alpine3.15 as go-builder

ARG DAPP_BRANCH="dapp/0.34.1"

RUN apk --no-cache add git

WORKDIR /go/src/ethsign

RUN git clone -b ${DAPP_BRANCH} https://github.com/dapphub/dapptools.git .

RUN export CGO_ENABLED=0 \
  && mkdir dist \
  && cd src/ethsign/ \
  && go mod tidy \
  && go mod download \
  && go build -o ../../dist/ethsign ./ethsign.go

FROM python:3.10.2-alpine3.15

ARG SETZER_BRANCH="v0.4.0"

RUN apk add --no-cache \
  bash jq curl git make perl g++ ca-certificates
RUN apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
  jshon agrep

ARG DAPP_BRANCH="dapp/0.34.1"

# Downloading dapp
RUN git clone -b ${DAPP_BRANCH} https://github.com/dapphub/dapptools.git \
  && cp -R dapptools/src/dapp/ /opt/dapp \
  && cp -R dapptools/src/seth/libexec/seth /opt/seth \
  && rm -rf dapptools

# Installing setzer
RUN git clone -b ${SETZER_BRANCH} https://github.com/makerdao/setzer-mcd.git \
  && cp -R setzer-mcd/libexec/setzer/ /opt/setzer \
  && rm -rf setzer-mcd

COPY --from=ethsign-builder /go/src/ethsign/dist/ /usr/local/bin/

COPY ./docker/geth/bin/hevm-0.48.1 /usr/local/bin/hevm
COPY ./docker/geth/bin/solc-0.5.12 /usr/local/bin/solc

ARG ORACLE_SUITE_VERSION="0.3.5"

# Downloading Spire from github releases
RUN mkdir spire_dist \
  && cd spire_dist \
  && wget https://github.com/chronicleprotocol/oracle-suite/releases/download/v${ORACLE_SUITE_VERSION}/spire_${ORACLE_SUITE_VERSION}_linux_arm64.tar.gz \
  && tar -xvzf spire_${ORACLE_SUITE_VERSION}_linux_arm64.tar.gz \
  && cp spire /usr/local/bin/ \
  && chmod +x /usr/local/bin/spire \
  && cd .. \
  && rm -rf spire_dist

# Downloading Gofer from github releases
RUN mkdir gofer_dist \
  && cd gofer_dist \
  && wget https://github.com/chronicleprotocol/oracle-suite/releases/download/v${ORACLE_SUITE_VERSION}/gofer_${ORACLE_SUITE_VERSION}_linux_arm64.tar.gz \
  && tar -xvzf gofer_${ORACLE_SUITE_VERSION}_linux_arm64.tar.gz \
  && cp gofer /usr/local/bin/ \
  && chmod +x /usr/local/bin/gofer \
  && cd .. \
  && rm -rf gofer_dist
  
# Downloading SSB RPC Client from github releases
RUN mkdir ssb-rpc-client_dist \
  && cd ssb-rpc-client_dist \
  && wget https://github.com/chronicleprotocol/oracle-suite/releases/download/v${ORACLE_SUITE_VERSION}/ssb-rpc-client_${ORACLE_SUITE_VERSION}_linux_arm64.tar.gz \
  && tar -xvzf ssb-rpc-client_${ORACLE_SUITE_VERSION}_linux_arm64.tar.gz \
  && cp ssb-rpc-client /usr/local/bin/ \
  && chmod +x /usr/local/bin/ssb-rpc-client \
  && cd .. \
  && rm -rf ssb-rpc-client_dist

ENV PATH="/opt/dapp/libexec/dapp:/opt/seth:/opt/setzer:${PATH}"

CMD ["/bin/bash"]