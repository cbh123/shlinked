defmodule Shlinkedin.Repo.Migrations.ChangeImageUrl do
  use Ecto.Migration

  def change do
    alter table(:content) do
      modify(:header_image, :text)
    end
  end
end
