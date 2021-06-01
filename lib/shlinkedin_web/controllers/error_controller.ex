defmodule ShlinkedinWeb.ErrorController do
  import Phoenix.Controller

  def index(conn, _params) do
    render(conn, "500.html")
  end
end
