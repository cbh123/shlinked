defmodule Shlinkedin.Repo.Migrations.DefaultFive do
  use Ecto.Migration

  def change do
    alter table :profiles do
      modify :ad_frequency, :integer, default: 5
    end
  end
end
