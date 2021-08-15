defmodule ShlinkedinWeb.SitemapControllerTest do
  use ShlinkedinWeb.ConnCase

  describe "GET /sitemap.xml" do
    test "accesses the sitemap in format xml", %{conn: conn} do
      conn = get(conn, "/sitemap.xml")
      assert response_content_type(conn, :xml)
    end
  end
end
