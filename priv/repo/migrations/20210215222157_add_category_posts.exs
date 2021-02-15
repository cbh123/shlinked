defmodule Shlinkedin.Repo.Migrations.AddCategoryPosts do
  use Ecto.Migration

  def change do
    alter table :posts do
      add :category, :string
    end
  end
end
