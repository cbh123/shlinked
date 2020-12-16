defmodule Shlinkedin.Repo.Migrations.AddInfoTypesToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :update_type, :string
      add :profile_update, :boolean
    end
  end
end
