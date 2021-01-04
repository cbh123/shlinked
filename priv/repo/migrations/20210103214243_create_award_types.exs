defmodule Shlinkedin.Repo.Migrations.CreateAwardTypes do
  use Ecto.Migration

  def change do
    create table(:award_types) do
      add :emoji, :string
      add :image_format, :string, default: "emoji"
      add :description, :string
      add :name, :string
      add :bg, :string
      add :color, :string, default: "text-blue-500"
      add :bg_hover, :string
      add :fill, :string, default: "even-odd"
      add :svg_path, :text

      timestamps()
    end

  end
end
