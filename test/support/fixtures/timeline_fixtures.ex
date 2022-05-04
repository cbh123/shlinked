defmodule Shlinkedin.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Timeline` context.
  """

  @doc """
  Generate a reward_message.
  """
  def reward_message_fixture(attrs \\ %{}) do
    {:ok, reward_message} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> Shlinkedin.Timeline.create_reward_message()

    reward_message
  end
end
