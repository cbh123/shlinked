defmodule Shlinkedin.Profiles.Testimonial do
  use Ecto.Schema
  import Ecto.Changeset

  schema "testimonials" do
    field :body, :string
    field :rating, :integer
    belongs_to :profile, Shlinkedin.Profiles.Profile, foreign_key: :from_profile_id
    field :to_profile_id, :id
    field :relation, :string
    timestamps()
  end

  @doc false
  def changeset(testimonials, attrs) do
    testimonials
    |> cast(attrs, [:body, :rating, :relation])
    |> validate_length(:body, min: 1, max: 300)
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_required([:body, :rating])
  end
end
