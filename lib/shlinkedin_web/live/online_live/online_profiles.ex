defmodule ShlinkedinWeb.OnlineLive.OnlineProfiles do
  use ShlinkedinWeb, :live_component

  def render(assigns) do
    ~L"""
    <div>
    <h2>Users online:</h2>
    <%= for profile <- @profiles |> Map.keys() do %>

      <span class="text-xs bg-blue-200 rounded px-2 py-1"><%= profile %></span>
    <% end %>

    </div>
    """
  end
end
