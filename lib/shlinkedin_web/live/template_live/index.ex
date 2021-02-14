defmodule ShlinkedinWeb.TemplateLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.Template

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    {:ok,
     check_access(socket)
     |> assign(live_action: socket.assigns.live_action || :index, templates: list_templates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Template")
    |> assign(:template, Timeline.get_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Template")
    |> assign(:template, %Template{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Templates")
    |> assign(:template, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    template = Timeline.get_template!(id)
    {:ok, _} = Timeline.delete_template(template)

    {:noreply, assign(socket, :templates, list_templates())}
  end

  defp list_templates do
    Timeline.list_templates()
  end

  defp check_access(socket) do
    case socket.assigns.profile.admin do
      false ->
        socket
        |> put_flash(:danger, "ACCESS DENIED")
        |> push_redirect(to: "/home")

      true ->
        socket
    end
  end
end
