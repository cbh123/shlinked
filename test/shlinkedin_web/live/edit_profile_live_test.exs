defmodule ShlinkedinWeb.EditProfileLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Shlinkedin.Profiles
  alias Shlinkedin.Repo

  setup :register_user_and_profile

  test "edit username / slug", %{conn: conn, profile: profile} do
    assert profile.slug == "charlie"
    assert profile.username == "charlie"

    {:ok, view, _html} = live(conn, Routes.profile_edit_path(conn, :edit))

    view |> render() =~ "Profile Editor 3000"

    {:ok, _, _html} =
      view
      |> form("#profile-form", profile: %{"username" => "charlop"})
      |> render_submit()
      |> follow_redirect(conn, Routes.profile_show_path(conn, :show, "charlop"))

    new_profile = Shlinkedin.Profiles.get_profile_by_slug("charlop")
    assert new_profile.id == profile.id
    assert new_profile.slug == "charlop"
    assert new_profile.username == "charlop"

    # do it again!
    {:ok, view, _html} = live(conn, Routes.profile_edit_path(conn, :edit))

    view |> render() =~ "Profile Editor 3000"

    {:ok, _, _html} =
      view
      |> form("#profile-form", profile: %{"username" => "charlop123"})
      |> render_submit()
      |> follow_redirect(conn, Routes.profile_show_path(conn, :show, "charlop123"))

    new_profile = Shlinkedin.Profiles.get_profile_by_slug("charlop123")
    assert new_profile.id == profile.id
    assert new_profile.slug == "charlop123"
    assert new_profile.username == "charlop123"
  end

  test "delete account", %{conn: conn, profile: profile} do
    {:ok, view, _html} = live(conn, Routes.profile_edit_path(conn, :edit))

    {:error, :nosession} =
      view
      |> render_click("delete-account")
      |> follow_redirect(conn)

    assert Profiles.get_profile_by_profile_id(profile.id)
           |> Repo.preload(:user) == nil

    assert Profiles.get_profile_by_profile_id(profile.id) == nil
  end
end
