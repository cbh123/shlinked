defmodule Shlinkedin.Feedback do
  @moduledoc """
  The Feedback context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo
  alias Shlinkedin.Feedback.Feedback

  def create_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    invite
    |> Feedback.changeset(attrs)
    |> Repo.insert()
  end
end
