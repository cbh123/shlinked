defmodule Shlinkedin.Repo.Migrations.AddHashtagsToSocialPrompts do
  use Ecto.Migration

  def change do
    alter table :social_prompts do
     add :hashtags, :string, default: "shlinkedin"
     add :via, :string, default: "shlinkedin"
    end
  end
end
