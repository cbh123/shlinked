defmodule ShlinkedinWeb.HeadlineController do
  use ShlinkedinWeb, :controller

  alias Shlinkedin.News

  action_fallback ShlinkedinWeb.FallbackController

  def index(conn, %{"type" => type, "time" => time, "page" => page}) do
    page = String.to_integer(page)

    headlines =
      News.list_articles([paginate: %{page: page, per_page: 15}], %{time: time, type: type})

    render(conn, "index.json", headlines: headlines)
  end

  def index(conn, _params) do
    headlines =
      News.list_articles([paginate: %{page: 1, per_page: 15}], %{time: "week", type: "new"})

    render(conn, "index.json", headlines: headlines)
  end
end
