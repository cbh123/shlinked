defmodule Shlinkedin.Repo.Migrations.EndorsementCascade do
  use Ecto.Migration

  def change do
    drop constraint(:endorsements, :endorsements_from_profile_id_fkey)

    alter table :endorsements do
      modify :from_profile_id, references(:profiles, on_delete: :delete_all)
    end
  end
end
