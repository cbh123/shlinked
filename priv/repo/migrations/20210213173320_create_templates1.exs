defmodule Shlinkedin.Repo.Migrations.CreateTemplates1 do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :title, :string
      add :body, :text

      timestamps()
    end

  end
end
