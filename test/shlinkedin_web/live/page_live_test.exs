defmodule ShlinkedinWeb.PageLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "ShlinkedIn"
  end
end
