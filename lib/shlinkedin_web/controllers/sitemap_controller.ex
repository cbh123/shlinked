defmodule ShlinkedinWeb.SitemapController do
  use ShlinkedinWeb, :controller

  def sitemap(conn, _params) do
    conn
    |> put_resp_content_type("text/xml")
    |> render("sitemap.xml")
  end
end
