defmodule Shlinkedin.Repo.Migrations.AddGeneratorUsed do
  use Ecto.Migration

  def change do
    alter table :posts do
      add :generator_type, :string
    end
  end
end
