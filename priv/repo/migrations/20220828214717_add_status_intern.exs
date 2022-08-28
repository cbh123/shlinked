defmodule Shlinkedin.Repo.Migrations.AddStatusIntern do
  use Ecto.Migration

  def change do
    alter table(:interns) do
      add :status, :string, default: "ALIVE"
    end
  end
end
