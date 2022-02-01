FROM ghcr.io/chronicleprotocol/omnia_base:latest

WORKDIR /home/dapp
COPY ./docker/geth/bin/median-deploy /usr/local/bin/median-deploy
COPY ./docker/keystore /root/keystore

RUN git clone --recurse-submodules https://github.com/makerdao/testchain-medians.git . \
  && dapp build

ENV ETH_RPC_URL=http://geth.local:8545
ENV ETH_GAS=7000000
ENV ETH_KEYSTORE=/root/keystore
ENV ETH_PASSWORD=/root/keystore/password
ENV ETH_FROM=0x1bb90cde8a032cb4963813a5b4db4981afa5b9c6

ENTRYPOINT [ "" ]