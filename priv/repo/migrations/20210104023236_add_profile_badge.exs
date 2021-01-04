defmodule Shlinkedin.Repo.Migrations.AddProfileBadge do
  use Ecto.Migration

  def change do
    alter table :award_types do
      add :profile_badge, :boolean, default: false
    end
  end
end
