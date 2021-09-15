defmodule Shlinkedin.Repo.Migrations.CreateSocialPrompts do
  use Ecto.Migration

  def change do
    create table(:social_prompts) do
      add :text, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end

  end
end
