defmodule Shlinkedin.Repo.Migrations.RemoveAuthorFromComments do
  use Ecto.Migration

  def up do
    alter table(:comments) do
      remove :author
    end
  end

  def down do
    alter table(:comments) do
      add :author, :string
    end
  end
end
