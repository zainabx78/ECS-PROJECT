# Stage 1: build stage
FROM node:24-slim as Build

# work out of /app
WORKDIR /app

# bring in the app code
COPY app/ .

# pnpm crashes without libatomic on slim
RUN apt-get update && apt-get install -y libatomic1 && rm -rf /var/lib/apt/lists/*

# install pnpm
RUN npm install -g pnpm

# install deps, cache the store so rebuilds are quicker
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# build the app
RUN pnpm build


# Stage 2: production stage
FROM node:24-slim

# same working folder
WORKDIR /app

# grab the built app from the build stage
COPY --from=build /app /app

# need libatomic again since this stage starts from scratch
RUN apt-get update && apt-get install -y libatomic1 && rm -rf /var/lib/apt/lists/*

# and pnpm for the start command
RUN npm install -g pnpm

# make a non-root user and give it the app files
RUN groupadd -r app && useradd -r -m -g app app && chown -R app:app /app

# don't run as root
USER app

# web port
EXPOSE 3000

# start it up
CMD ["pnpm", "start"]