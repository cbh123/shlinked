defmodule Shlinkedin.Repo.Migrations.DropRealName do
  use Ecto.Migration

  def change do
    alter table :profiles do
      remove :real_name, :string
    end
  end
end
