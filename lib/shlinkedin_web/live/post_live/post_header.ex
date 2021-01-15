defmodule ShlinkedinWeb.PostLive.PostHeader do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Timeline.Post

  def render(assigns) do
    ~L"""
    <div class="ml-2 sm:ml-4 mt-2 sm:mt-3">
    <div class="flex items-center">
        <div class="flex-shrink-0">
            <span class="inline-block relative">
                <img class="h-10 w-10 sm:h-12 sm:w-12 rounded-full object-cover"
                    src="<%= @post.profile.photo_url %>" alt="">
                <span
                    class="absolute bottom-0 right-0 block h-2 w-2 rounded-full ring-2 ring-white bg-green-400"></span>
            </span>
        </div>
        <div class="ml-3 sm:ml-4 cursor-pointer w-64 text-gray-500 truncate overflow-hidden">


            <span class="text-gray-900 ">

                <%= live_redirect @post.profile.persona_name, to: Routes.profile_show_path(@socket, :show, @post.profile.slug), class: "text-sm font-semibold text-gray-900 hover:underline"  %>
                <%= Shlinkedin.Badges.profile_badges(assigns, @post.profile, 3) %>

            </span>

            <%= case get_group_name(@post) do %>
            <% nil -> %>
            <span
                class="text-gray-500 font-normal <%= if @post.profile_update, do: "text-sm", else: "text-xs"%>">
                <%= if @post.profile_update == true, do: "updated their #{@post.update_type}", else: @post.profile.persona_title  %>
            </span>

            <% group -> %>

            <%= live_redirect to: Routes.group_show_path(@socket, :show, group.id) do %>

            <span class="text-gray-500 mx-1">
              &rarr;
            </span>


            <div class="inline-flex text-blue-500 <%= if group.header_font == nil, do: "font-normal", else: "font-#{group.header_font}" %> font-semibold hover:underline text-xs">
            <span class="inline-flex">

            <svg class="w-3 h-3 place-self-center mr-1" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z"></path></svg>
            </span>
            <span class="">



            <%= group.title %>
            </span>
            </div>

            <% end %>


            <% end %>



            <p class="text-xs text-gray-500">
                <%= Timex.from_now(@post.inserted_at) %>
            </p>



        </div>
    </div>
    </div>
    """
  end

  defp get_group_name(%Post{group_id: nil}), do: nil

  defp get_group_name(%Post{group_id: id}), do: Shlinkedin.Groups.get_group!(id)
end
