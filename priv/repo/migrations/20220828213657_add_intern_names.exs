defmodule Shlinkedin.Repo.Migrations.AddInternNames do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :intern_names, {:array, :string}, default: []
    end
  end
end
