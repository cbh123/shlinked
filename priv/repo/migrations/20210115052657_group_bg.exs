defmodule Shlinkedin.Repo.Migrations.GroupBg do
  use Ecto.Migration

  def change do
    alter table :groups do
      add :bg_color, :string, default: "#f1f5f9"
    end
  end
end
