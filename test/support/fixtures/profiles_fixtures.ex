defmodule Shlinkedin.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Profiles` context.
  """
  alias Shlinkedin.Profiles

  @testimonial %{body: "some body", rating: 3}
  @endorsement %{body: "some body"}

  def unique_persona_name, do: "Mr. #{System.unique_integer()}} Beans"
  def title, do: "Product Manager"
  def unique_slug, do: "profile_#{:rand.uniform(100_000)}"

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

  def profile_fixture_user(user, attrs \\ %{}) do
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

  def endorsement_fixture(from, to, attrs \\ %{}) do
    {:ok, endorsement} = Profiles.create_endorsement(from, to, attrs |> Enum.into(@endorsement))

    endorsement
  end

  def testimonial_fixture(from, to, attrs \\ %{}) do
    {:ok, testimonial} = Profiles.create_testimonial(from, to, attrs |> Enum.into(@testimonial))

    testimonial
  end

  def profile_view_fixture(from, to) do
    {:ok, profile_view} = Profiles.create_profile_view(from, to)

    profile_view
  end

  @doc """
  Generate a work.
  """
  def work_fixture(attrs \\ %{}) do
    {:ok, work} =
      attrs
      |> Enum.into(%{

      })
      |> Shlinkedin.Profiles.create_work()

    work
  end
end
