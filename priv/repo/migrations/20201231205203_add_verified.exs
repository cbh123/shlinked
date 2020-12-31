defmodule Shlinkedin.Repo.Migrations.AddVerified do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :verified_date, :naive_datetime
    end
  end
end
