defmodule Shlinkedin.Repo.Migrations.AddResumeLink do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :resume_link, :text
    end
  end
end
