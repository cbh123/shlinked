defmodule Shlinkedin.Repo.Migrations.AddSubjectToNotification do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :subject, :string
    end
  end
end
