defmodule Shlinkedin.Profiles.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :read, :boolean, default: false
    belongs_to :profile, Shlinkedin.Profiles.Profile, foreign_key: :from_profile_id
    field :to_profile_id, :id
    field :post_id, :id, on_delete: :nilify_all
    field :article_id, :id, on_delete: :nilify_all
    field :group_id, :id, on_delete: :nilify_all
    field :ad_id, :id, on_delete: :nilify_all
    field :type, :string
    field :body, :string
    field :subject, :string
    field :link, :string
    field :action, :string
    field :notify_all, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :from_profile_id,
      :to_profile_id,
      :post_id,
      :ad_id,
      :group_id,
      :type,
      :action,
      :subject,
      :body,
      :link,
      :read,
      :notify_all
    ])
  end
end
