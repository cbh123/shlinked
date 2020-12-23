defmodule Shlinkedin.Repo.Migrations.TestimonyLonger do
  use Ecto.Migration

  def change do
    alter table(:testimonials) do
      modify :body, :text
    end

  end
end
