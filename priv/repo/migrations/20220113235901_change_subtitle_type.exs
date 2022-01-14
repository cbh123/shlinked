defmodule Shlinkedin.Repo.Migrations.ChangeSubtitleType do
  use Ecto.Migration

  def change do
    alter table(:content) do
      modify :subtitle, :text
    end
  end
end
