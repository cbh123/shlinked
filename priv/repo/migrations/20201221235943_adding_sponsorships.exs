defmodule Shlinkedin.Repo.Migrations.AddingSponsorships do
  use Ecto.Migration

  def change do
    alter table(:stories) do
      add :sponsored, :boolean, default: false
    end
  end
end
