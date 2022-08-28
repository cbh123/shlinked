defmodule Shlinkedin.Interns.Intern do
  use Ecto.Schema
  import Ecto.Changeset

  schema "interns" do
    field :age, :integer
    field :last_fed, :naive_datetime
    field :name, :string
    field :status, :string, default: "ALIVE"
    belongs_to :profile, Shlinkedin.Profiles.Profile

    field :address, :string
    field :education, :string
    field :major, :string
    field :gpa, :string
    field :summary, :string
    field :company1_name, :string
    field :company1_job, :string
    field :company1_title, :string
    field :company2_name, :string
    field :company2_job, :string
    field :company2_title, :string
    field :company3_name, :string
    field :company3_job, :string
    field :company3_title, :string
    field :hobbies, :string
    field :reference, :string

    timestamps()
  end

  @doc false
  def changeset(intern, attrs) do
    intern
    |> cast(attrs, [
      :name,
      :age,
      :last_fed,
      :status,
      :address,
      :education,
      :major,
      :gpa,
      :summary,
      :company1_name,
      :company1_job,
      :company1_title,
      :company2_name,
      :company2_job,
      :company2_title,
      :company3_name,
      :company3_job,
      :company3_title,
      :hobbies,
      :reference
    ])
    |> validate_required([:name, :age, :last_fed])
  end
end
