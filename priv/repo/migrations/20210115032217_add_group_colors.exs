defmodule Shlinkedin.Repo.Migrations.AddGroupColors do
  use Ecto.Migration

  def change do
    alter table :groups do
      add :header_bg_color, :string, default: "#FFFFFF"
      add :header_text_color, :string
      add :header_font, :string
    end
  end
end
