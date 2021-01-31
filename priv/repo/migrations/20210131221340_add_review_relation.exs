defmodule Shlinkedin.Repo.Migrations.AddReviewRelation do
  use Ecto.Migration

  def change do
    alter table :testimonials do
      add :relation, :string
    end
  end
end
