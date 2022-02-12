# Stage 1: Build a Mix.Release of the application (image size: ~750mb)
FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder

WORKDIR /app

# These two environment variables will be overwritten when the application is started.
# They are needed here to satisfy the env-variable checks in `prod.secret.exs`
ENV SECRET_KEY_BASE=nokey
ENV DATABASE_URL=nodb

# If you set the PORT to 4000, you need to change it in the fly.toml as well.
ENV PORT=4000
ENV MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile

# Cache npm deps
ADD assets/package.json assets/
RUN npm install --prefix assets

# Copy all local files to the build context
# Ignores the ones specified in .dockerignore
ADD . .

# Run frontend build, compile, and digest assets
RUN npm run --prefix assets deploy
RUN mix do compile, phx.digest

# Create a Mix.Release of the application
RUN mix release

# Stage 2: Create a smaller deployment image (image size: ~98mb)
FROM bitwalker/alpine-elixir:latest

# Make sure that this PORT is equal to the one above
# and to the one in fly.toml
ENV PORT=4000
ENV MIX_ENV=prod

WORKDIR /app

# Create a unprivileged user to run the app
#
# This is a common security practice to avoid
# giving root permissions to the application which attackers
# could potentially abuse if they gain access to the application.
ENV USER="phoenix"
ENV HOME=/home/"${USER}"
ENV APP_DIR="${HOME}/app"
RUN \
    addgroup \
    -g 1000 \
    -S "${USER}" && \
    adduser \
    -s /bin/sh \
    -u 1000 \
    -G "${USER}" \
    -h "${HOME}" \
    -D "${USER}" && \
    su "${USER}" sh -c "mkdir ${APP_DIR}"

# Copy the files necessary to run the application
COPY --from=phx-builder --chown="${USER}":"${USER}" /app/_build/prod/rel/my_app ./
COPY --from=phx-builder --chown="${USER}":"${USER}" /app/entrypoint.sh ./

# Define the entrypoint and the command it should execute
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["bin/my_app", "start"]
