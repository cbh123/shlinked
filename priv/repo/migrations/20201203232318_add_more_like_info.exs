defmodule Shlinkedin.Repo.Migrations.AddMoreLikeInfo do
  use Ecto.Migration

  def change do
    alter table(:likes) do
      remove :from_name
    end
  end
end
