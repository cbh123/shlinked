defmodule Shlinkedin.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Timeline` context.
  """
  alias Shlinkedin.Timeline

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

    add_likes({3, post})
  end

  def headline_fixture(attrs \\ %{}) do
    profile = Shlinkedin.ProfilesFixtures.profile_fixture()

    {:ok, headline} =
      Shlinkedin.News.create_article(
        profile,
        %Shlinkedin.News.Article{},
        attrs
        |> Enum.into(%{
          headline: "this just in"
        })
      )

    headline
  end

  defp add_likes({num_likes, post}) do
    Enum.each(
      1..num_likes,
      fn _num ->
        Timeline.create_like(Shlinkedin.ProfilesFixtures.profile_fixture(), post, "nice")
      end
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
