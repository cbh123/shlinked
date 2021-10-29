defmodule ShlinkedinWeb.PostController do
  use ShlinkedinWeb, :controller

  alias Shlinkedin.Timeline

  action_fallback ShlinkedinWeb.FallbackController

  def index(conn, %{"type" => type, "time" => time, "page" => page}) do
    page = String.to_integer(page)

    posts =
      Timeline.list_posts(nil, [paginate: %{page: page, per_page: 15}], %{time: time, type: type})

    render(conn, "index.json", posts: posts)
  end

  def index(conn, _params) do
    posts =
      Timeline.list_posts(nil, [paginate: %{page: 1, per_page: 15}], %{time: "week", type: "new"})

    render(conn, "index.json", posts: posts)
  end
end
