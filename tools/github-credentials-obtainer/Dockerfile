FROM node:20-alpine

WORKDIR /app

COPY package.json ./

RUN npm install

COPY script.js ./

LABEL org.opencontainers.image.source=https://github.com/quantified-uncertainty/ops

CMD ["node", "./script.js"]
