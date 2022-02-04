FROM node@sha256:366c71eebb0da62a832729de2ffc974987b5b00ab25ed6a5bd8d707219b65de4

RUN apk add bash

COPY ./docker/ssb-server/state/db /root/.ssb/db
COPY ./docker/ssb-server/config/manifest.json /root/.ssb/manifest.json

RUN npm install -g --no-optional ssb-server

# Disable 'sodium-native' warning message
ENV CHLORIDE_JS='1'

EXPOSE 8000

CMD [ "ssb-server", "start" ]
