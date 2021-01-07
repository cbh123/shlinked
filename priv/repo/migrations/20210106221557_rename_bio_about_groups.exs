defmodule Shlinkedin.Repo.Migrations.RenameBioAboutGroups do
  use Ecto.Migration

  def change do
    rename table("groups"), :bio, to: :about
  end
end
