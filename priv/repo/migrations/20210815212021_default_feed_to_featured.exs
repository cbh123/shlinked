defmodule Shlinkedin.Repo.Migrations.DefaultFeedToFeatured do
  use Ecto.Migration

  def change do
    alter table :profiles do
      modify :feed_type, :string, default: "featured"
    end
  end
end
