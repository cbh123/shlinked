defmodule ShlinkedinWeb.PostLive.PostComponent do
  use ShlinkedinWeb, :live_component
  alias ShlinkedinWeb.PostLive.PostComponent
  alias Shlinkedin.Timeline.Post
  alias Shlinkedin.Timeline
  alias Shlinkedin.Profiles.Profile

  def handle_event("show-likes", %{"id" => id}, %{assigns: %{return_to: return_to}} = socket) do
    post = Timeline.get_post_preload_profile(id)

    socket =
      socket
      |> assign(:page_title, "Reactions")
      |> assign(
        :grouped_likes,
        Timeline.list_likes(post)
        |> Enum.group_by(&%{name: &1.name, photo_url: &1.photo_url, slug: &1.slug})
      )

    case return_to do
      "/" -> {:noreply, push_patch(socket, to: "/home/posts/#{post.id}/likes")}
      other -> {:noreply, push_patch(socket, to: other <> "/posts/#{post.id}/likes")}
    end
  end

  def handle_event("toggle-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: !socket.assigns.show_post_options
    )

    {:noreply, socket}
  end

  def handle_event("feature-post", _params, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)
    poster = Shlinkedin.Profiles.get_profile_by_profile_id(socket.assigns.post.profile_id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        featured: true,
        featured_date: NaiveDateTime.utc_now()
      })
      |> Shlinkedin.Profiles.ProfileNotifier.observer(:featured_post, %Profile{id: 3}, poster)

    socket =
      socket
      |> put_flash(:info, "Post featured!")
      |> push_redirect(to: "/home")

    {:noreply, socket}
  end

  def handle_event("unfeature-post", _, socket) do
    post = Timeline.get_post!(socket.assigns.post.id)

    {:ok, _post} =
      Timeline.update_post(socket.assigns.profile, post, %{
        featured: false
      })

    socket =
      socket
      |> put_flash(:info, "Post un-featured!")
      |> push_redirect(to: "/home")

    {:noreply, socket}
  end

  def handle_event("hide-post-options", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      show_post_options: false
    )

    {:noreply, socket}
  end

  def handle_event("expand-comments", _, socket) do
    send_update(PostComponent,
      id: socket.assigns.post.id,
      num_show_comments: socket.assigns.num_show_comments + 5
    )

    {:noreply, socket}
  end

  def handle_event("like-selected", %{"like-type" => like_type}, socket) do
    Shlinkedin.Timeline.create_like(socket.assigns.profile, socket.assigns.post, like_type)

    send_update(PostComponent,
      id: socket.assigns.post.id,
      spin: true,
      expand_post: true
    )

    send_update_after(
      PostComponent,
      [id: socket.assigns.post.id, spin: false],
      1000
    )

    {:noreply, socket}
  end

  defp featured_post_header(assigns, post) do
    ~L"""
        <%# Post of Day tag %>
        <%= if post.featured do %>
        <span
            class="bg-white absolute rounded-full r top-1 right-1 inline-flex items-center px-1 py-0.5 text-xs font-medium text-yellow-500">


            <%= if post.featured_date != nil and Timex.diff(post.featured_date, Timex.now(), :days) == 0 do %>
            <span class="italic pr-1">Post of the Day</span>
            <% end %>

            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd"
                    d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z"
                    clip-rule="evenodd"></path>
            </svg>
        </span>
        <% end %>

    """
  end

  defp post_header(assigns, post) do
    ~L"""
    <div class="ml-2 sm:ml-4 mt-2 sm:mt-3">
    <div class="flex items-center">
        <div class="flex-shrink-0">
            <span class="inline-block relative">
                <img class="h-10 w-10 sm:h-12 sm:w-12 rounded-full object-cover"
                    src="<%= post.profile.photo_url %>" alt="">
                <span
                    class="absolute bottom-0 right-0 block h-2 w-2 rounded-full ring-2 ring-white bg-green-400"></span>
            </span>
        </div>
        <div class="ml-3 sm:ml-4 cursor-pointer w-64 text-gray-500 truncate overflow-hidden">


            <span class="text-gray-900 ">

                <%= live_redirect post.profile.persona_name, to: Routes.profile_show_path(assigns, :show, post.profile.slug), class: "text-sm font-semibold text-gray-900 hover:underline"  %>
                <%= Shlinkedin.Badges.profile_badges(assigns, post.profile, 3) %>

            </span>
            <span
                class="text-gray-500 <%= if post.profile_update, do: "text-sm", else: "text-xs"%> font-normal">
                <%= if post.profile_update == true, do: "updated their #{post.update_type}", else: post.profile.persona_title  %>
            </span>


            <p class="text-xs text-gray-500">
                <%= Timex.from_now(post.inserted_at) %>
            </p>



        </div>
    </div>
    </div>
    """
  end

  defp censor_tag(assigns, post) do
    ~L"""
    <%= if post.censor_tag == true do %>
    <div>
        <div class="rounded-md bg-blue-50 p-4">
            <div class="flex">
                <div class="flex-shrink-0">
                    <!-- Heroicon name: information-circle -->
                    <svg class="h-5 w-5 text-blue-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"
                        fill="currentColor" aria-hidden="true">
                        <path fill-rule="evenodd"
                            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                            clip-rule="evenodd" />
                    </svg>
                </div>
                <div class="ml-3 flex-1 md:flex md:justify-between">
                    <p class="text-sm text-blue-700">
                        <%= post.censor_body %>
                    </p>
                </div>
            </div>
        </div>
    </div>
    <% end %>
    """
  end

  defp show_unique_likes(%Post{} = post) do
    Enum.map(post.likes, fn x -> x.like_type end) |> Enum.uniq()
  end

  defp length_unique_user_likes(%Post{} = post) do
    uniq = Enum.map(post.likes, fn x -> x.profile_id end) |> Enum.uniq() |> length

    case uniq do
      1 -> "1 person"
      uniq -> "#{uniq} people"
    end
  end

  defp like_map_list(like_map) do
    Enum.filter(like_map, fn {_, d} -> d.active end) |> Enum.map(fn {_, d} -> d end)
  end

  defp show_author(profile, post_profile) do
    case Shlinkedin.Profiles.show_real_name(profile, post_profile) do
      "" -> "Mystery"
      name -> name
    end
  end
end
