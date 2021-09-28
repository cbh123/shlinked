defmodule Shlinkedin.Repo.Migrations.AddAdIdToModActions do
  use Ecto.Migration

  def change do
    alter table :mod_actions do
      add :ad_id, references(:ads, on_delete: :nothing)
      add :comment_id, references(:comments, on_delete: :nothing)
    end

    create index(:mod_actions, [:ad_id])
    create index(:mod_actions, [:comment_id])
  end
end
