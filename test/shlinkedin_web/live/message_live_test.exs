defmodule Shlinkedin.MessageLiveTest do
  use ShlinkedinWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_user_and_profile

  test "navigate to shlinkmail", %{conn: conn} do
    {:ok, _index_live, html} = live(conn, Routes.message_index_path(conn, :index))

    assert html =~ "ShlinkMail"
  end

  test "click new message", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.message_index_path(conn, :index))

    assert html =~ "ShlinkMail"

    view |> element("#new-message") |> render_click()

    assert_patch(view, Routes.message_index_path(conn, :new_message))

    assert render(view) =~ "New ShlinkMail"

    assert render(view) =~ "📮"

    # todo: if a profile has a friend, it should show up as suggested friend. test that suggested friends show up
  end
end
