defmodule ShlinkedinWeb.MetaAttrs do
  import Plug.Conn
  import Phoenix.Controller

  def put_meta_attrs(conn, meta_attrs) do
    assign(conn, :meta_attrs, [])
  end
end
