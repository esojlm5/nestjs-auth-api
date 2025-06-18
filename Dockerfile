# Base stage
FROM node:20-slim as base
WORKDIR /app

RUN apt-get update -y && \
  apt-get install -y openssl procps ca-certificates && \
  rm -rf /var/lib/apt/lists/*

RUN rm -rf /usr/local/bin/yarn && \
  npm install -g yarn@1.22.19 --force && \
  yarn --version

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

RUN yarn prisma generate

# Development stage
FROM base as development
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
CMD [, "yarn", "start:dev"]

# Production stage
FROM base as production
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
RUN yarn build && yarn install --production --frozen-lockfile
CMD [, "yarn", "start"]
