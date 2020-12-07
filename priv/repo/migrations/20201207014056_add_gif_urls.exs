defmodule Shlinkedin.Repo.Migrations.AddGifUrls do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :gif_url, :string
    end
  end
end
