# Stage 1: Build Phoenix app
FROM "bitwalker/alpine-elixir-phoenix:1.10.3" as phx-builder

RUN apk add --no-cache yarn

ARG SECRET_KEY_BASE
ARG DATABASE_URL

ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV DATABASE_URL=$DATABASE_URL

COPY . .

RUN mix do deps.get, deps.compile
RUN cd assets && yarn install && webpack --mode production && cd ..
RUN mix do compile, phx.digest, release

# Stage 2: Copy phoenix binary over
FROM bitwalker/alpine-elixir:1.10.3

COPY --from=phx-builder /opt/app/_build/prod/rel/hotex /opt/app

ARG HOST
ARG PORT
ARG SECRET_KEY_BASE
ARG DATABASE_URL

ENV MIX_ENV=prod
ENV HOST=$HOST
ENV PORT=$PORT
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV DATABASE_URL=$DATABASE_URL

# Run migration before starting server
RUN echo "bin/hotex eval \"Hotex.Tasks.migrate\"" > run.sh
RUN echo "bin/hotex start" >> run.sh

EXPOSE $PORT

ENTRYPOINT sh run.sh
