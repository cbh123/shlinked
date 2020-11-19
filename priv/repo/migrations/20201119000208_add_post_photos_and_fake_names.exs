defmodule Shlinkedin.Repo.Migrations.AddPostPhotosAndFakeNames do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :post_name, :string
      add :post_profile_picture, :string
      add :post_title, :string
    end
  end
end
