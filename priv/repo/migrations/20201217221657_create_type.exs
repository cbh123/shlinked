defmodule Shlinkedin.Repo.Migrations.CreateType do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :last_read, :naive_datetime
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)
      add :type, :string

      timestamps()
    end

    create index(:notifications, [:from_profile_id])
    create index(:notifications, [:to_profile_id])
    create index(:notifications, [:post_id])
  end
end
