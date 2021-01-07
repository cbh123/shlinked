defmodule Shlinkedin.Repo.Migrations.AddPrivacyTypeDeletePublic do
  use Ecto.Migration

  def change do
    alter table :groups do
      remove :public
      add :privacy_type, :string
    end
  end
end
