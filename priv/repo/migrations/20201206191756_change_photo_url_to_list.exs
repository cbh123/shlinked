defmodule Shlinkedin.Repo.Migrations.ChangePhotoUrlToList do
  use Ecto.Migration

  def change do
    alter table(:posts) do
        add :photo_urls, {:array, :string}, default: []
        remove :photo_url
    end
  end
end
