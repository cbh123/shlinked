defmodule Shlinkedin.Repo.Migrations.AddSummariesAndVerifiedAndPhotoUrl do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :summary, :text
      add :verified, :boolean
      add :photo_url, :string
      add :cover_photo_url, :string
      add :shlinkpoints, :integer, default: 0
    end
  end
end
