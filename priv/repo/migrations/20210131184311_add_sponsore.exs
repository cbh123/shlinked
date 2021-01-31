defmodule Shlinkedin.Repo.Migrations.AddSponsore do
  use Ecto.Migration

  def change do
   alter table :posts do
    add :sponsored, :boolean, default: false
   end
  end
end
