defmodule Shlinkedin.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :status, :text
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:invites, [:from_profile_id])
    create index(:invites, [:to_profile_id])
  end
end
