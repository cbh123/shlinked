defmodule Shlinkedin.Repo.Migrations.AddExpirationToAwwardType do
  use Ecto.Migration

  def change do
    alter table :award_types do
      add :profile_badge_days, :integer, default: 10000
    end
  end
end
