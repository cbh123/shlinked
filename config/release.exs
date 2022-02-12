import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

app_name =
  System.get_env("FLY_APP_NAME") ||
    raise "FLY_APP_NAME not available"

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :my_app, Shlinkedin.Repo,
  url: database_url,
  # DON'T FORGET THE FOLLOWING LINE
  socket_options: [:inet6],
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :my_app, Shlinkedin.Endpoint,
  server: true,
  secret_key_base: secret_key_base,
  load_from_system_env: true,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "#{app_name}.fly.dev", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
