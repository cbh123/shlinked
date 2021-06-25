defmodule ShlinkedinWeb.HomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline

  setup :register_user_and_profile

  test "initial render", %{conn: conn, profile: _profile} do
    {:ok, view, _html} =
      conn
      |> live("/marketplace")

    assert render(view) =~ "ShlinkMarket"
  end
end
