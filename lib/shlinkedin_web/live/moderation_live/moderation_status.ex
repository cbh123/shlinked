defmodule ShlinkedinWeb.ModerationLive.ModerationStatus do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Moderation

  defp list_actions(content) do
    Shlinkedin.Moderation.list_actions(content)
  end

  def handle_event("undo-all", _, socket) do
    {:ok, content} = Shlinkedin.Moderation.delete_all(socket.assigns.content)
    {:noreply, socket |> assign(content: content)}
  end

  def render(assigns) do
    ~L"""
    <%= if @content.removed and Shlinkedin.Profiles.is_moderator?(@profile) do %>
    <div class="mx-auto max-w-lg">


    <!-- This example requires Tailwind CSS v2.0+ -->
    <div class="rounded-md bg-red-50 p-4">
    <div class="flex">
    <div class="flex-shrink-0">
    <!-- Heroicon name: solid/x-circle -->
    <svg class="h-5 w-5 text-red-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
    </svg>
    </div>
    <div class="ml-3">
    <h3 class="text-sm font-medium text-red-800">
      This content is censored — it will not show up in feeds / market / profiles. Reason:
    </h3>
    <div class="mt-2 text-sm text-red-700">
      <ul role="list" class="list-disc pl-5 space-y-1">
        <%= for action <- list_actions(@content) do %>
        <li>
          <%= action.reason %>
        </li>
        <% end %>
      </ul>
    </div>

    </div>

    </div>
    <button phx-click="undo-all" phx-target="<%= @myself %>"
    class="mt-4 ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
    Undo All Moderation
    </button>
    </div>
    </div>
    <% end %>
    """
  end
end
