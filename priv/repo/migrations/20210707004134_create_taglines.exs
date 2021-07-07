defmodule Shlinkedin.Repo.Migrations.CreateTaglines do
  use Ecto.Migration

  def change do
    create table(:taglines) do
      add :text, :string
      add :active, :boolean, default: true, null: false

      timestamps()
    end

  end
end
