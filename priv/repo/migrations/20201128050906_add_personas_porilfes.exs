defmodule Shlinkedin.Repo.Migrations.AddPersonasToProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :persona_name, :string
      add :persona_title, :string
    end
  end
end
