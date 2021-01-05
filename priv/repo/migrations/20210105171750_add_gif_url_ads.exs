defmodule Shlinkedin.Repo.Migrations.AddGifUrlAds do
  use Ecto.Migration

  def change do
    alter table :ads do
      add :gif_url, :string
    end
  end
end
