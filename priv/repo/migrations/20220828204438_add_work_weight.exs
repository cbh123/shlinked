defmodule Shlinkedin.Repo.Migrations.AddWorkWeight do
  use Ecto.Migration

  def change do
    alter table(:work) do
      add :weight, :integer, default: 1
    end
  end
end
