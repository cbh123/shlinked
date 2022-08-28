defmodule Shlinkedin.InternsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Interns` context.
  """

  @doc """
  Generate a intern.
  """
  def intern_fixture(attrs \\ %{}) do
    {:ok, intern} =
      attrs
      |> Enum.into(%{
        age: 42,
        last_fed: ~N[2022-08-27 21:40:00],
        name: "some name"
      })
      |> Shlinkedin.Interns.create_intern()

    intern
  end
end
