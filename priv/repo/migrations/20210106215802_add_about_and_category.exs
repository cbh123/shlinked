defmodule Shlinkedin.Repo.Migrations.AddAboutAndCategory do
  use Ecto.Migration

  def change do
    alter table :groups do
      add :bio, :text
      add :categories, {:array, :string}
    end
  end
end
