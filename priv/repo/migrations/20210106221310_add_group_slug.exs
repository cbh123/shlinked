defmodule Shlinkedin.Repo.Migrations.AddGroupSlug do
  use Ecto.Migration

  def change do
    alter table :groups do
      add :slug, :string
    end
  end
end
