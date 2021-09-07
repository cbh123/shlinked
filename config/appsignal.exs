use Mix.Config

config :appsignal, :config,
  otp_app: :shlinkedin,
  name: "shlinkedin",
  push_api_key: System.fetch_env!("APPSIGNAL_PUSH_API_KEY"),
  env: Mix.env()
