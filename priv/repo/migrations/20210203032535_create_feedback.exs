defmodule Shlinkedin.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :category, :string
      add :body, :string
      add :from_email, :string
      timestamps()
    end

  end
end
