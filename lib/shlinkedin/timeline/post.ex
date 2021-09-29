defmodule Shlinkedin.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shlinkedin.Profiles.Profile

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
    field :group_id, :integer
    field :sponsored, :boolean, default: false
    field :template, :string, virtual: true
    field :category, :string
    field :generator_type, :string
    field :pinned, :boolean, default: false
    field :removed, :boolean, default: false
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
      :profile_tags,
      :group_id,
      :sponsored,
      :template,
      :category,
      :generator_type,
      :pinned,
      :inserted_at,
      :removed
    ])
    |> validate_required([])
    |> add_theme()
    |> validate_length(:body, max: 4000)
  end

  defp add_theme(changeset) do
    case Map.get(changeset.changes, :body) do
      nil -> changeset
      text -> Ecto.Changeset.put_change(changeset, :category, select_theme(text))
    end
  end

  defp select_theme(text) do
    if text |> String.downcase() |> String.contains?("#cybersecurity"),
      do: "cybersecurity",
      else: ""
  end

  @doc """
  Validates on back end that the current profile is allowed to
  make the changes they're attempting to.
  """
  def validate_allowed(changeset, post, profile) do
    validate_change(changeset, :body, fn :body, _body ->
      if is_allowed?(profile, post.profile_id) do
        []
      else
        [body: "You cannot edit this person's posts."]
      end
    end)
  end

  defp is_allowed?(%Profile{admin: true}, _post_profile_id) do
    true
  end

  defp is_allowed?(%Profile{id: id}, post_profile_id) do
    id == post_profile_id
  end
end
