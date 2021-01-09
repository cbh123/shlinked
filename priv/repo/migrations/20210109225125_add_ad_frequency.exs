defmodule Shlinkedin.Repo.Migrations.AddAdFrequency do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :ad_frequency, :integer, default: 7
    end
  end
end
