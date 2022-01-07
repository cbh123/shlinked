defmodule Shlinkedin.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:content) do
      add :author, :string
      add :content, :text
      add :header_image, :string
      add :twitter, :string
      add :title, :string
      add :subtitle, :string
      add :tags, {:array, :string}

      timestamps()
    end
  end
end
