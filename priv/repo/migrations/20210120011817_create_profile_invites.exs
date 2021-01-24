defmodule Shlinkedin.Repo.Migrations.CreateProfileInvites do
  use Ecto.Migration

  def change do
    create table(:profile_invites) do
      add :email, :string
      add :body, :string
      add :name, :string
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:profile_invites, [:profile_id])
  end
end
