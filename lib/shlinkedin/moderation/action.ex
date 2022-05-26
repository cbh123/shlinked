defmodule Shlinkedin.Moderation.Action do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mod_actions" do
    field :action, :string
    field :reason, :string
    belongs_to :profile, Shlinkedin.Profiles.Profile
    field :post_id, :id
    field :article_id, :id
    field :ad_id, :id
    field :comment_id, :id

    timestamps()
  end

  @doc false
  def changeset(actions, attrs) do
    actions
    |> cast(attrs, [:action, :reason])
    |> validate_required([:action, :reason])
  end
end
