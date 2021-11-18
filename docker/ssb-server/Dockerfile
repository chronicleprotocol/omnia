FROM node:lts-alpine3.14

RUN apk add bash

COPY docker/ssb-server/config/secret /root/.ssb/secret
COPY docker/ssb-server/config/manifest.json /root/.ssb/manifest.json

RUN npm install -g --no-optional ssb-server

# Disable 'sodium-native' warning message
ENV CHLORIDE_JS='1'

EXPOSE 8008

CMD [ "ssb-server", "start" ]