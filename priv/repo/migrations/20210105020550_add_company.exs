defmodule Shlinkedin.Repo.Migrations.AddCompany do
  use Ecto.Migration

  def change do
    alter table :ads do
      add :company, :string
      add :product, :string
      add :overlay, :string
    end
  end
end
