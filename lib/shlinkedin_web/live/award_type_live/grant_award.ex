defmodule ShlinkedinWeb.AwardTypeLive.GrantAward do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Awards
  alias Shlinkedin.Profiles

  def handle_event("grant", %{"id" => award_type_id}, socket) do
    case socket.assigns.profile.admin do
      true ->
        award_type = Awards.get_award_type!(award_type_id)
        {:ok, _award} = Profiles.grant_award(socket.assigns.to_profile, award_type)

        {:noreply,
         socket |> assign(current_awards: Profiles.list_awards(socket.assigns.to_profile))}

      false ->
        {:noreply, socket}
    end
  end

  def handle_event("revoke-award", %{"id" => award_id}, socket) do
    case socket.assigns.profile.admin do
      true ->
        award = Profiles.get_award!(award_id)
        {:ok, _} = Profiles.revoke_award(award)

        {:noreply,
         socket |> assign(current_awards: Profiles.list_awards(socket.assigns.to_profile))}

      false ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~L"""
    <div class="p-5 ">



    <h1 class="font-bold mb-2"><%= @to_profile.persona_name %> Current Awards <span class="text-gray-500 italic">Click to revoke

    </span>
    </h1>
    <%= for award <- @current_awards do %>
    <button phx-target="<%= @myself %>" phx-click="revoke-award" data-confirm="are you sure you want to revoke award?" phx-value-id="<%= award.id %>" id="current-award-<%= award.id %>" class="hover:bg-gray-50 rounded inline-flex border shadow rounded px-4 py-2 ">
    <p class="whitespace-nowrap text-sm font-medium text-gray-900"><%= award.award_type.name %>
    </p>
        <%= if award.award_type.image_format == "svg" do  %>
        <div class="inline-flex ml-3 <%= award.award_type.color %>">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="<%= award.award_type.fill%>" d="<%= award.award_type.svg_path %>"
                    clip-rule="<%= award.award_type.fill%>">
                </path>
            </svg>
        </div>
        <% else %>
        <%= award.award_type.emoji %>
        <% end %>


    </button>
    <% end %>

    <hr class="my-4"/>
    <h1 class="font-bold">Available Awards</h1>

    <%= for award <- @award_types do %>

    <button data-confirm="are you sure you want to add award? they will be notified"
    phx-target="<%= @myself %>" phx-click="grant" phx-value-id="<%= award.id %>" id="award-<%= award.id %>"
    class="hover:bg-gray-50 rounded m-1 inline-flex border shadow rounded px-4 py-2 ">
        <p class="whitespace-nowrap text-sm font-medium text-gray-900"><%= award.name %>
        </p>
            <%= if award.image_format == "svg" do  %>
            <div class="inline-flex <%= award.color %>">
                <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"
                    xmlns="http://www.w3.org/2000/svg">
                    <path fill-rule="<%= award.fill%>" d="<%= award.svg_path %>"
                        clip-rule="<%= award.fill%>">
                    </path>
                </svg>
            </div>
            <% else %>
            <%= award.emoji %>
            <% end %>


            <%= if award.profile_badge do %>
            <p class="text-gray-500 text-xs pl-3">
            Stays next to name for <%= if award.profile_badge_days == 10000, do: "forever", else: "#{award.profile_badge_days} days"  %></p>
          <% end %>
    </button>
    <% end %>

    """
  end
end
