defmodule Shlinkedin.Repo.Migrations.AdFreqTo3 do
  use Ecto.Migration

  def change do
    alter table :profiles do
      modify :ad_frequency, :integer, default: 3
    end
  end
end
