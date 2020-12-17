defmodule Shlinkedin.Repo.Migrations.DefaultProfUpdateFalse do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :profile_update, :boolean, default: false
    end
  end
end
