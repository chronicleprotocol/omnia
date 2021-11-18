FROM node:lts-alpine3.14

RUN apk add bash

COPY docker/ssb-server/state/db /root/.ssb/db
COPY docker/ssb-server/config/manifest.json /root/.ssb/manifest.json

RUN npm install -g --no-optional ssb-server

# Disable 'sodium-native' warning message
ENV CHLORIDE_JS='1'

EXPOSE 8008

CMD [ "ssb-server", "start" ]