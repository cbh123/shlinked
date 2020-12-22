defmodule Shlinkedin.Timeline.StoryView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "story_views" do
    belongs_to :story, Shlinkedin.Timeline.Story
    belongs_to :profile, Shlinkedin.Profiles.Profile, foreign_key: :from_profile_id

    timestamps()
  end

  @doc false
  def changeset(story_view, attrs) do
    story_view
    |> cast(attrs, [])
    |> validate_required([])
  end
end
