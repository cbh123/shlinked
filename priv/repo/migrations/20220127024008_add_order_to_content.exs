defmodule Shlinkedin.Repo.Migrations.AddOrderToContent do
  use Ecto.Migration

  def change do
    alter table(:content) do
      add :priority, :integer, default: 1
    end
  end
end
