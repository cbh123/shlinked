defmodule Shlinkedin.Repo.Migrations.AddTagsToComments do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :profile_tags, {:array, :string}, default: []
    end

  end
end
