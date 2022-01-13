defmodule Shlinkedin.Repo.Migrations.AddHeaderImageSubtitle do
  use Ecto.Migration

  def change do
    alter table(:content) do
      add :header_image_subtitle, :string
    end
  end
end
