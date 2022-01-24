defmodule Shlinkedin.Repo.Migrations.AlterContentTag do
  use Ecto.Migration

  def change do
    alter table(:content) do
      add :topic, :string
      remove :tags, {:array, :string}
    end
  end
end
