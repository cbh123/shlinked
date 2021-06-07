defmodule ShlinkedinWeb.ErrorViewTest do
  use ShlinkedinWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 500.html", %{conn: conn} do
    conn = get(conn, Routes.error_path(conn, :index))
    response = html_response(conn, 200)
    assert response =~ "dang it"
  end
end
