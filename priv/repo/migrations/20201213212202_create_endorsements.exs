defmodule Shlinkedin.Repo.Migrations.CreateEndorsements do
  use Ecto.Migration

  def change do
    create table(:endorsements) do
      add :emoji, :string
      add :body, :string
      add :gif_url, :string
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:endorsements, [:from_profile_id])
    create index(:endorsements, [:to_profile_id])
  end
end
