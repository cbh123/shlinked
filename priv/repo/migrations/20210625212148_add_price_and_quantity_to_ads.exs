defmodule Shlinkedin.Repo.Migrations.AddPriceAndQuantityToAds do
  use Ecto.Migration

  def change do
    alter table :ads do
      add :quantity, :integer, default: 1
      add :price, :integer, default: 10000
    end
  end
end
