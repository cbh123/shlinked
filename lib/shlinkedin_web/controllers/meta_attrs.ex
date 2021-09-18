defmodule ShlinkedinWeb.MetaAttrs do
  import Plug.Conn

  def put_meta_attrs(conn, _meta_attrs) do
    assign(conn, :meta_attrs, [])
  end
end
