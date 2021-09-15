defmodule Shlinkedin.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Timeline` context.
  """

  def random_body, do: "Hey there, this is  Post ##{System.unique_integer()}} hahahah"

  def post_fixture(attrs \\ %{}) do
    profile = Shlinkedin.ProfilesFixtures.profile_fixture()

    {:ok, post} =
      Shlinkedin.Timeline.create_post(
        profile,
        attrs
        |> Enum.into(%{
          "body" => random_body()
        })
      )

    post
  end

  def post_fixture_with_profile(profile, attrs \\ %{}) do
    {:ok, post} =
      Shlinkedin.Timeline.create_post(
        profile,
        attrs
        |> Enum.into(%{
          "body" => random_body()
        })
      )

    post
  end
end
