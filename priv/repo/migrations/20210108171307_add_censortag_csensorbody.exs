defmodule Shlinkedin.Repo.Migrations.AddCensortagCsensorbody do
  use Ecto.Migration

  def change do
    alter table :posts do
      add :censor_tag, :boolean, default: false
      add :censor_body, :string
    end
  end
end
