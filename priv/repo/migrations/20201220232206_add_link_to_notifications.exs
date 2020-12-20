defmodule Shlinkedin.Repo.Migrations.AddLinkToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :link, :string
    end
  end
end
