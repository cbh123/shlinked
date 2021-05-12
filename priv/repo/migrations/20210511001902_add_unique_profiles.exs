defmodule Shlinkedin.Repo.Migrations.AddUniqueProfiles do
  use Ecto.Migration

  def change do
    alter table(:chat_conversations) do
      add(:profile_ids, {:array, :integer}, unique: true, null: false)
    end

    create(unique_index(:chat_conversations, [:profile_ids]))
  end
end
