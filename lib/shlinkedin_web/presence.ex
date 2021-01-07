defmodule ShlinkedinWeb.Presence do
  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: Shlinkedin.PubSub
end
