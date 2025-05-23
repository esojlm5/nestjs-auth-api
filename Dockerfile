# Use Node.js LTS version
FROM node:20-slim as base

# Set working directory
WORKDIR /app

# Install OpenSSL and other necessary dependencies
RUN apt-get update -y && \
  apt-get install -y openssl procps && \
  apt-get update && apt-get install -y ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# Force install specific yarn version and verify
RUN rm -rf /usr/local/bin/yarn && \
  npm install -g yarn@1.22.19 --force && \
  yarn --version

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application
COPY . .

# Generate Prisma client
RUN yarn prisma generate

# Development stage
FROM base as development
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
CMD ["/app/start.sh", "yarn", "start:dev"]

# Production stage
FROM base as production
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
RUN yarn build
CMD ["/app/start.sh", "yarn", "start:dev"] 
