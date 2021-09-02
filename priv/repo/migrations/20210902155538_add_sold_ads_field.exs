defmodule Shlinkedin.Repo.Migrations.AddSoldAdsField do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :show_sold_ads, :boolean, default: false
    end
  end
end
