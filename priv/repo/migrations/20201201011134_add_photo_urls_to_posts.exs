defmodule Shlinkedin.Repo.Migrations.AddPhotoUrlsToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :photo_url, :string
    end
  end
end
