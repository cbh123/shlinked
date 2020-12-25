defmodule Shlinkedin.Repo.Migrations.OnDeleteNotification do
  use Ecto.Migration

  def up do
    drop(constraint(:notifications, "notifications_post_id_fkey"))

    alter table(:notifications) do
      modify(:post_id, references(:posts, on_delete: :nilify_all))
    end
  end

  def down do
    drop(constraint(:notifications, "notifications_post_id_fkey"))

    alter table(:notifications) do
      modify(:post_id, references(:posts, on_delete: :nothing))
    end
  end
end
