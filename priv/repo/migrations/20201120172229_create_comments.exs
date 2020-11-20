defmodule Shlinkedin.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :string
      add :author, :string
      add :likes, :integer
      add :post_id, references(:posts)

      timestamps()
    end
  end
end
