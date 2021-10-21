defmodule Shlinkedin.Repo.Migrations.AddHeadlineSortOptions do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :headline_type, :string, default: "reactions"
      add :headline_time, :string, default: "week"
    end
  end
end
