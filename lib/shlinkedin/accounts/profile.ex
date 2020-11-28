defmodule Shlinkedin.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :username, :string
    field :slug, :string
    field :persona_name, :string
    field :persona_title, :string
    belongs_to :user, Shlinkedin.Accounts.User
    has_many :posts, Shlinkedin.Timeline.Post
    has_many :comments, Shlinkedin.Timeline.Comment
    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:username, :user_id, :slug, :persona_name, :persona_title])
    |> validate_required([:user_id])
    |> unique_constraint([:user_id])
    |> validate_username()
    |> validate_slug()
  end

  defp validate_username(changeset) do
    changeset
    |> validate_format(:username, ~r/^(?!.*[_.]{2})[^_.].*[^_.]$/,
      message: "invalid username -- no special characters!"
    )
    |> validate_length(:username, min: 3, max: 20)
    |> unique_constraint([:username])
  end

  defp validate_slug(changeset) do
    changeset
    |> validate_format(:slug, ~r/^(?!.*[_.]{2})[^_.].*[^_.]$/,
      message: "invalid url -- no special characters!"
    )
    |> validate_length(:slug, min: 3, max: 20)
    |> unique_constraint([:slug])
  end
end
