defmodule Shlinkedin.Profiles.FollowsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shlinkedin.Profiles.Follows` context.
  """
  import Shlinkedin.ProfilesFixtures

  @doc """
  Generate a follow.
  """
  def follow_fixture() do
    p1 = profile_fixture()
    p2 = profile_fixture()
    {:ok, follow} = Shlinkedin.Profiles.create_follow(p1, p2)

    follow
  end
end
