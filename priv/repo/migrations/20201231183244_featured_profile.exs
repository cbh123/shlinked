defmodule Shlinkedin.Repo.Migrations.FeaturedProfile do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :featured, :boolean, default: false
      add :featured_date, :naive_datetime
    end
  end
end
