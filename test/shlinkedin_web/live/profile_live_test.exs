defmodule ShlinkedinWeb.ProfileLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.ProfilesFixtures
  alias Shlinkedin.Profiles

  setup :register_user_and_profile

  test "profile view has to be unique per day", %{conn: conn, profile: _profile} do
    random_profile = profile_fixture()

    {:ok, view, _html} = live(conn, Routes.profile_show_path(conn, :show, random_profile.slug))

    random_profile = Profiles.get_profile_by_profile_id(random_profile.id)

    assert random_profile.points.amount == 110
    {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, random_profile.slug))
    {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, random_profile.slug))
    {:ok, _view, _html} = live(conn, Routes.profile_show_path(conn, :show, random_profile.slug))
    assert random_profile.points.amount == 110
  end
end
