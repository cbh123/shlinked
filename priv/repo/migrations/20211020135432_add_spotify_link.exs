defmodule Shlinkedin.Repo.Migrations.AddSpotifyLink do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :spotify_song_url, :string
    end

  end
end
