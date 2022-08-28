defmodule Shlinkedin.Repo.Migrations.AddInternDetails do
  use Ecto.Migration

  def change do
    alter table(:interns) do
      add :address, :string
      add :education, :string
      add :major, :string
      add :gpa, :string
      add :summary, :string
      add :company1_name, :string
      add :company1_job, :string
      add :company1_title, :string
      add :company2_name, :string
      add :company2_job, :string
      add :company2_title, :string
      add :company3_name, :string
      add :company3_job, :string
      add :company3_title, :string
      add :hobbies, :string
      add :reference, :string
    end
  end
end
