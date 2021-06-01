defmodule ShlinkedinWeb.PageLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  setup :register_user_and_profile

  test "renders", %{conn: conn, profile: _profile} do
    {:ok, _page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "ShlinkedIn"
  end
end
