defmodule Shlinkedin.MessageLiveTest do
  use ShlinkedinWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_user_and_profile
  import Shlinkedin.ProfilesFixtures

  test "navigate to shlinkmail", %{conn: conn} do
    {:ok, _index_live, html} = live(conn, Routes.message_index_path(conn, :index))

    assert html =~ "ShlinkMail"
  end

  test "click new message", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.message_index_path(conn, :index))

    assert html =~ "ShlinkMail"

    view |> element("a", "New") |> render_click()

    assert_patch(view, Routes.message_index_path(conn, :new_message))

    assert render(view) =~ "New ShlinkMail"

    assert render(view) =~ "📮"

    # todo: if a profile has a friend, it should show up as suggested friend. test that suggested friends show up
  end

  test "select someone to message", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.message_index_path(conn, :index))
    other = profile_fixture()

    assert html =~ "ShlinkMail"

    view |> element("a", "New") |> render_click()

    assert_patch(view, Routes.message_index_path(conn, :new_message))

    # assert we can search profiles
    assert view |> element("#search-profiles") |> render_change(%{"q" => "Cha"}) =~ "Charlie"

    {:ok, _view, _html} =
      view
      |> element("#result-#{other.id}")
      |> render_click()
      |> follow_redirect(conn)
  end

  test "select someone to message and then message them", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.message_index_path(conn, :index))
    other = profile_fixture()

    assert html =~ "ShlinkMail"

    view |> element("a", "New") |> render_click()

    assert_patch(view, Routes.message_index_path(conn, :new_message))

    # assert we can search profiles
    assert view |> element("#search-profiles") |> render_change(%{"q" => "Cha"}) =~ "Charlie"

    {:ok, view, _html} =
      view
      |> element("#result-#{other.id}")
      |> render_click()
      |> follow_redirect(conn)

    view
    |> element("#send-message")
    |> render_submit(%{"message" => %{"content" => "hi there"}})

    assert render(view) =~ "hi there"
  end

  test "select someone to message and then message them preservers order", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.message_index_path(conn, :index))
    other = profile_fixture()

    assert html =~ "ShlinkMail"

    view |> element("a", "New") |> render_click()

    assert_patch(view, Routes.message_index_path(conn, :new_message))

    # assert we can search profiles
    assert view |> element("#search-profiles") |> render_change(%{"q" => "Cha"}) =~ "Charlie"

    {:ok, view, _html} =
      view
      |> element("#result-#{other.id}")
      |> render_click()
      |> follow_redirect(conn)

    Enum.each([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], fn i ->
      view
      |> element("#send-message")
      |> render_submit(%{"message" => %{"content" => "number #{i}"}})
    end)

    # {:ok, view, html} = live(conn, Routes.message_show_path(conn, :show, ))
  end
end
