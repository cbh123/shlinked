defmodule Shlinkedin.Repo.Migrations.CreateModActions do
  use Ecto.Migration

  def change do
    create table(:mod_actions) do
      add :action, :string, null: false
      add :reason, :string
      add :profile_id, references(:profiles, on_delete: :nothing), null: false
      add :post_id, references(:posts, on_delete: :nothing)
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps()
    end

    create index(:mod_actions, [:profile_id])
    create index(:mod_actions, [:post_id])
    create index(:mod_actions, [:article_id])
  end
end
