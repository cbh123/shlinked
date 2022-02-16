defmodule Shlinkedin.Repo.Migrations.AddConfettiEmoji do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :confetti_emoji, :text
    end
  end
end
