defmodule Shlinkedin.Repo.Migrations.RemoveAd do
  use Ecto.Migration

  def change do
    alter table :ads do
      add :removed, :boolean, default: :false
    end
  end
end
