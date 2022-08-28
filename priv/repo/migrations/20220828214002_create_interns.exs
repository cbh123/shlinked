defmodule Shlinkedin.Repo.Migrations.CreateInterns do
  use Ecto.Migration

  def change do
    create table(:interns) do
      add :name, :string
      add :age, :integer
      add :last_fed, :naive_datetime
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end
  end
end
