defmodule Shlinkedin.Repo.Migrations.CreateModerators do
  use Ecto.Migration

  def change do
    create table(:moderators) do
      add :powers, {:array, :string}
      add :profile_id, references(:profiles, on_delete: :nothing), unique: true

      timestamps()
    end

    create index(:moderators, [:profile_id])
  end
end
