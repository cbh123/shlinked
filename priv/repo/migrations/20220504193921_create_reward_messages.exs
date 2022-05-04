defmodule Shlinkedin.Repo.Migrations.CreateRewardMessages do
  use Ecto.Migration

  def change do
    create table(:reward_messages) do
      add :text, :string

      timestamps()
    end
  end
end
