defmodule Shlinkedin.Repo.Migrations.AddTagsToCommentsForReal do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :profile_tags, {:array, :string}, default: []
    end
  end
end
