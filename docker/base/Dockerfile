# ethsign build stage
FROM golang:1-alpine as ethsign-builder

ARG ETH_SIGN_BRANCH="ethsign/0.17.0"

RUN apk --no-cache add git

WORKDIR /go/src/ethsign

RUN git clone -b ${ETH_SIGN_BRANCH} https://github.com/dapphub/dapptools.git .

RUN export CGO_ENABLED=0 \
  && mkdir dist \
  && cd src/ethsign/ \
  && go mod tidy \
  && go mod download \
  && go build -o ../../dist/ethsign ./ethsign.go

# Final image
FROM alpine:edge

ARG DAPP_BRANCH="dapp/0.34.1"
ARG SETZER_BRANCH="v0.4.0"

# Disable 'sodium-native' warning message
ENV CHLORIDE_JS='1'

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  bash jq curl git nodejs npm python3 make jshon perl agrep g++ ca-certificates

# Downloading dapp
RUN git clone -b ${DAPP_BRANCH} https://github.com/dapphub/dapptools.git \
  && cp -R dapptools/src/dapp/ /root/dapp \
  && cp -R dapptools/src/seth/libexec/seth /root/seth \
  && rm -rf dapptools

# Installing setzer
RUN git clone -b ${SETZER_BRANCH} https://github.com/makerdao/setzer-mcd.git \
  && cp -R setzer-mcd/libexec/setzer/ /root/setzer \
  && rm -rf setzer-mcd

COPY --from=ethsign-builder /go/src/ethsign/dist/ /usr/local/bin/

COPY ./docker/geth/bin/hevm-0.48.1 /usr/local/bin/hevm
COPY ./docker/geth/bin/solc-0.5.12 /usr/local/bin/solc

# Downloading Spire from github releases
RUN mkdir spire_dist \
  && cd spire_dist \
  && wget https://github.com/chronicleprotocol/oracle-suite/releases/download/v0.3.2/spire_0.3.2_linux_arm64.tar.gz \
  && tar -xvzf spire_0.3.2_linux_arm64.tar.gz \
  && cp spire /usr/local/bin/ \
  && chmod +x /usr/local/bin/spire \
  && cd .. \
  && rm -rf spire_dist

# Downloading Gofer from github releases
RUN mkdir gofer_dist \
  && cd gofer_dist \
  && wget https://github.com/chronicleprotocol/oracle-suite/releases/download/v0.3.2/gofer_0.3.2_linux_arm64.tar.gz \
  && tar -xvzf gofer_0.3.2_linux_arm64.tar.gz \
  && cp gofer /usr/local/bin/ \
  && chmod +x /usr/local/bin/gofer \
  && cd .. \
  && rm -rf gofer_dist
  
# Installing ssb client only
RUN npm install -g --no-optional ssb-server

ENV PATH="/root/dapp/libexec/dapp:/root/seth:/root/setzer:${PATH}"

CMD ["/bin/bash"]