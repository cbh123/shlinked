defmodule Shlinkedin.Repo do
  use Ecto.Repo,
    otp_app: :shlinkedin,
    adapter: Ecto.Adapters.Postgres
end
