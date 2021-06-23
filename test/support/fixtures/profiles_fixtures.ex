defmodule Shlinkedin.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Profiles` context.
  """

  def unique_persona_name, do: "Mr. #{System.unique_integer()} Beans"
  def title, do: "Product Manager"
  def unique_slug, do: "profile_#{:rand.uniform(10000)}"

  def profile_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user, Shlinkedin.AccountsFixtures.user_fixture())

    {:ok, profile} =
      Shlinkedin.Profiles.create_profile(
        user,
        attrs
        |> Enum.into(%{
          "persona_name" => unique_persona_name(),
          "slug" => unique_slug(),
          "title" => title(),
          "username" => unique_slug()
        })
      )

    profile
  end
end
