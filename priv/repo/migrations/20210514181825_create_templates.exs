defmodule Shlinkedin.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:message_templates) do
      add :content, :text
      add :type, :string

      timestamps()
    end

  end
end
