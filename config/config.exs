# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :shlinkedin,
  ecto_repos: [Shlinkedin.Repo]

# config/config.exs
config :shlinkedin, Shlinkedin.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

# Configures the endpoint
config :shlinkedin, ShlinkedinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fNbu+cPivBuXaOxrZhaGCheLwkzl4oiVgpxCFE65onLpGeHDg2qUY/MfL0t+TJLG",
  render_errors: [view: ShlinkedinWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Shlinkedin.PubSub,
  live_view: [signing_salt: "aeT/X9uj"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
