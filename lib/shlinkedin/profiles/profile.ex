defmodule Shlinkedin.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @username_regex ~r/^(?![_.])(?!.*[_.]{2})[a-z0-9._]+(?<![_.])$/

  schema "profiles" do
    field :username, :string
    field :slug, :string
    field :persona_name, :string
    field :persona_title, :string
    field :summary, :string
    field :verified, :boolean

    field :photo_url, :string,
      default:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/George_Washington%2C_1776.jpg/1200px-George_Washington%2C_1776.jpg"

    field :cover_photo_url, :string
    field :shlinkpoints, :integer, default: 0
    belongs_to :user, Shlinkedin.Accounts.User
    has_many :posts, Shlinkedin.Timeline.Post
    has_many :comments, Shlinkedin.Timeline.Comment
    has_many :endorsements, Shlinkedin.Profiles.Endorsement

    field :life_score, :string, default: "B+"
    field :points, :integer, default: 100

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :username,
      :user_id,
      :slug,
      :persona_name,
      :persona_title,
      :summary,
      :photo_url,
      :cover_photo_url,
      :life_score
    ])
    |> validate_required([:user_id, :persona_name, :username])
    |> downcase_username()
    |> unique_constraint([:user_id])
    |> validate_length(:persona_name, min: 1, max: 40)
    |> validate_length(:persona_title, min: 3, max: 100)
    |> validate_length(:summary, max: 500)
    |> validate_length(:life_score, max: 10)
    |> validate_username()
    |> validate_slug()
  end

  defp downcase_username(changeset) do
    update_change(changeset, :username, &String.downcase/1)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_format(:username, @username_regex,
      message: "Invalid username: no capitalizations or special characters!"
    )
    |> validate_length(:username, min: 3, max: 15)
    |> unique_constraint([:username])
  end

  defp validate_slug(changeset) do
    changeset
    |> validate_format(:slug, @username_regex, message: "invalid url -- no special characters!")
    |> validate_length(:slug, min: 3, max: 15)
    |> unique_constraint([:slug])
  end
end
