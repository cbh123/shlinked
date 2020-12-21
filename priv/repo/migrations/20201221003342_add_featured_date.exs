defmodule Shlinkedin.Repo.Migrations.AddFeaturedDate do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :featured_date, :naive_datetime
    end
  end
end
