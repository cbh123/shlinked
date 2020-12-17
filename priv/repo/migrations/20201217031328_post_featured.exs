defmodule Shlinkedin.Repo.Migrations.PostFeatured do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :featured, :boolean, default: false
    end
  end
end
