defmodule Shlinkedin.NewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.News` context.
  """

  @doc """
  Generate a content.
  """
  def content_fixture(attrs \\ %{}) do
    {:ok, content} =
      attrs
      |> Enum.into(%{
        author: "some author",
        content: "some content"
      })
      |> Shlinkedin.News.create_content()

    content
  end
end
