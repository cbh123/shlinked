defmodule Shlinkedin.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :status, :string
      add :message, :string
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:friends, [:from_profile_id])
    create index(:friends, [:to_profile_id])
  end
end
