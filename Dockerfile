# use the official Bun image
# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM oven/bun:1 AS build
WORKDIR /usr/src/app

COPY package.json bun.lockb ./
# use ignore-scripts to avoid builtind node modules like better-sqlite3
RUN bun install --frozen-lockfile --ignore-scripts

# Copy the entire project
COPY . .

# [optional] tests & build
ENV NODE_ENV=production
RUN bun test
RUN bun --bun run build


# copy production dependencies and source code into final image
FROM oven/bun:1 AS production
WORKDIR /usr/src/app
#  Only need the output folder
COPY --from=build /usr/src/app/.output /usr/src/app

# run the app
EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "--bun", "run", "server/index.mjs" ]
