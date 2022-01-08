defmodule Shlinkedin.NewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.News` context.
  """

  @doc """
  Generate a content.
  """
  def content_fixture(attrs \\ %{}) do
    profile = Shlinkedin.ProfilesFixtures.profile_fixture(%{"admin" => true})

    {:ok, content} =
      Shlinkedin.News.create_content(
        profile,
        attrs
        |> Enum.into(%{
          author: "some author",
          content: "some content",
          header_image: "some header image",
          twitter: "some twitter",
          title: "some title"
        })
      )

    content
  end
end
