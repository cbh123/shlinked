defmodule ShlinkedinWeb.AdminLive.Index do
  use ShlinkedinWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    case socket.assigns.profile.admin do
      false ->
        {:ok,
         socket
         |> put_flash(:danger, "ACCESS DENIED")
         |> push_redirect(to: "/")}

      true ->
        {:ok, socket}
    end
  end
end
