defmodule Shlinkedin.Timeline.Story do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stories" do
    belongs_to(:profile, Shlinkedin.Profiles.Profile)
    has_many(:story_views, Shlinkedin.Timeline.StoryView)
    field :media_url, :string
    field :body, :string
    field :sponsored, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(stories, attrs) do
    stories
    |> cast(attrs, [:body, :sponsored])
    |> validate_length(:body, max: 100)
    |> validate_required([:media_url])
  end
end
