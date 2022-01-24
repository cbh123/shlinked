defmodule Shlinkedin.Repo.Migrations.DefaultContentTwitterToShlinkedin do
  use Ecto.Migration

  def change do
    alter table(:content) do
      modify :twitter, :string, default: "https://twitter.com/ShlinkedIn"
    end
  end
end
