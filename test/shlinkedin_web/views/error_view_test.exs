defmodule ShlinkedinWeb.ErrorViewTest do
  use ShlinkedinWeb.ConnCase, async: true

  test "renders 500.html", %{conn: conn} do
    conn = get(conn, Routes.error_path(conn, :index))
    response = html_response(conn, 200)
    assert response =~ "charlie@shlinkedin.com"
  end
end
