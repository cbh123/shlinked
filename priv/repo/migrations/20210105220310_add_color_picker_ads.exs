defmodule Shlinkedin.Repo.Migrations.AddColorPickerAds do
  use Ecto.Migration

  def change do
    alter table :ads do
      add :overlay_color, :string
    end
  end
end
