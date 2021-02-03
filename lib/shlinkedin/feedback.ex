defmodule Shlinkedin.Feedback do
  @moduledoc """
  The Feedback context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo
  alias Shlinkedin.Feedback.Feedback

  def create_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.insert()
  end

  def change_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    Feedback.changeset(feedback, attrs)
  end
end
