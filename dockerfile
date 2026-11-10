
# Stage 1 - Build Stage
FROM node:24-slim as Build 

WORKDIR /app

COPY app/ .

RUN apt-get update && apt-get install -y libatomic1 && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile


RUN pnpm build


# Stage 2 - Production stage
FROM node:24-slim

WORKDIR /app

COPY --from=build /app /app

RUN apt-get update && apt-get install -y libatomic1 && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm

# Running as non-root user
RUN groupadd -r app && useradd -r -m -g app app && chown -R app:app /app
USER app

# The port the application uses inside container - just for documentation.
EXPOSE 3000

CMD ["pnpm", "start"]