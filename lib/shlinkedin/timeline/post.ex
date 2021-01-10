defmodule Shlinkedin.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field(:likes_count, :integer, default: 0)
    has_many(:comments, Shlinkedin.Timeline.Comment, on_delete: :nilify_all)
    has_many(:likes, Shlinkedin.Timeline.Like, on_delete: :nilify_all)
    belongs_to(:profile, Shlinkedin.Profiles.Profile)
    field :photo_urls, {:array, :string}, default: []
    field :gif_url, :string
    field :add_gif, :boolean, virtual: true
    field :update_type, :string
    field :profile_update, :boolean, default: false
    field :featured, :boolean, default: false
    field :featured_date, :naive_datetime
    field :profile_tags, {:array, :string}, default: []
    field :censor_tag, :boolean, default: false
    field :censor_body, :string
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :body,
      :update_type,
      :profile_update,
      :featured,
      :featured_date,
      :gif_url,
      :profile_tags
    ])
    |> validate_required([])
    |> validate_length(:body, max: 2000)
  end
end
