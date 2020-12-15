defmodule Shlinkedin.Repo.Migrations.CreateTestimonials do
  use Ecto.Migration

  def change do
    create table(:testimonials) do
      add :body, :string
      add :rating, :integer
      add :from_profile_id, references(:profiles, on_delete: :nothing)
      add :to_profile_id, references(:profiles, on_delete: :nothing)

      timestamps()
    end

    create index(:testimonials, [:from_profile_id])
    create index(:testimonials, [:to_profile_id])
  end
end
