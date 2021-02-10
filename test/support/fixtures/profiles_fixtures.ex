defmodule Shlinkedin.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Profiles` context.
  """

  def unique_persona_name, do: "Mr. #{System.unique_integer()} Beans"
  def title, do: "Product Manager"
  def unique_slug, do: "profile_#{:rand.uniform(10000)}"

  def profile_fixture(%Shlinkedin.Accounts.User{} = user, attrs \\ %{}) do
    {:ok, profile} =
      Shlinkedin.Profiles.create_profile(
        user,
        attrs
        |> Enum.into(%{
          "persona_name" => unique_persona_name(),
          "slug" => unique_slug(),
          "title" => title(),
          "real_name" => "Charlie Holtz",
          "username" => unique_slug()
        })
      )

    profile
  end
end
