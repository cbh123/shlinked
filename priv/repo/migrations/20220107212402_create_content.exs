defmodule Shlinkedin.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:content) do
      add :author, :string
      add :content, :text
      add :header_image, :string
      add :twitter, :string
      add :title, :string
      add :subtitle, :string
      add :tags, {:array, :string}
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:content, [:profile_id])
  end
end
