defmodule Shlinkedin.Repo.Migrations.AddRealName do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :real_name, :string
    end
  end
end
