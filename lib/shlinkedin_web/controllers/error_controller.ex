defmodule ShlinkedinWeb.ErrorController do
  use ShlinkedinWeb, :controller
  import Phoenix.Controller

  def index(conn, _params) do
    render(conn, "500.html")
  end
end
