defmodule Shlinkedin.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :title, :string
      add :public, :boolean, default: false, null: false
      add :cover_photo_url, :string

      timestamps()
    end

  end
end
