defmodule Shlinkedin.Profiles.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :last_read, :naive_datetime
    field :from_profile_id, :id
    field :to_profile_id, :id
    field :post_id, :id
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:last_read])
    |> validate_required([:last_read])
  end
end
