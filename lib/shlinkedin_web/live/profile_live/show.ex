defmodule ShlinkedinWeb.ProfileLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Timeline
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.Endorsement
  alias Shlinkedin.Profiles.Testimonial

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    show_profile = Shlinkedin.Profiles.get_profile_by_slug(slug)

    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(
       like_map: Timeline.like_map(),
       comment_like_map: Timeline.comment_like_map(),
       page: 1,
       per_page: 5,
       num_show_comments: 1
     )
     |> fetch_posts(show_profile)
     |> assign(live_action: socket.assigns.live_action || :show)
     |> assign(page_title: "Shlinked - " <> show_profile.persona_name)
     |> assign(from_notifications: false)
     |> assign(current_awards: Profiles.list_awards(show_profile))
     |> assign(award_types: Shlinkedin.Awards.list_award_types())
     |> assign(show_profile: show_profile)
     |> assign(from_profile: socket.assigns.profile)
     |> assign(to_profile: show_profile)
     |> assign(connections: Profiles.get_connections(show_profile))
     |> assign(friend_status: check_between_friend_status(socket.assigns.profile, show_profile))
     |> assign(endorsements: list_endorsements(show_profile.id))
     |> assign(mutual_friends: get_mutual_friends(socket.assigns.profile, show_profile))
     |> assign(testimonials: list_testimonials(show_profile.id)), temporary_assigns: [posts: []]}
  end

  defp fetch_posts(%{assigns: %{page: page, per_page: per}} = socket, %Profile{} = profile) do
    assign(socket,
      posts: Timeline.list_profile_posts([paginate: %{page: page, per_page: per}], profile)
    )
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :from_notifications, _params) do
    socket
    |> assign(:from_notifications, true)
  end

  defp apply_action(socket, :edit_endorsement, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Endorsement")
    |> assign(:endorsement, Profiles.get_endorsement!(id))
  end

  defp apply_action(socket, :edit_testimonial, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Review")
    |> assign(:testimonial, Profiles.get_testimonial!(id))
  end

  defp apply_action(socket, :new_endorsement, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Endorse #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:endorsement, %Endorsement{})
  end

  defp apply_action(socket, :new_testimonial, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Write a review for #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:testimonial, %Testimonial{})
  end

  defp apply_action(socket, :edit_awards, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Grant Award to #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:awards, Shlinkedin.Awards.list_award_types())
    |> assign(:current_awards, Profiles.list_awards(socket.assigns.show_profile))
  end

  @impl true
  def handle_event("delete-endorsement", %{"id" => id}, socket) do
    endorsement = Profiles.get_endorsement!(id)
    {:ok, _} = Profiles.delete_endorsement(endorsement)

    {:noreply, assign(socket, :endorsements, list_endorsements(socket.assigns.to_profile.id))}
  end

  @impl true
  def handle_event("delete-testimonial", %{"id" => id}, socket) do
    testimonial = Profiles.get_testimonial!(id)
    {:ok, _} = Profiles.delete_testimonial(testimonial)

    {:noreply, assign(socket, :testimonials, list_testimonials(socket.assigns.to_profile.id))}
  end

  def handle_event("send-friend-request", _, socket) do
    Profiles.send_friend_request(socket.assigns.from_profile, socket.assigns.to_profile)
    status = check_between_friend_status(socket.assigns.profile, socket.assigns.to_profile)

    {:noreply,
     socket
     |> assign(friend_status: status)}
  end

  def handle_event("unfriend", _, socket) do
    Profiles.cancel_friend_request(socket.assigns.from_profile, socket.assigns.to_profile)
    status = check_between_friend_status(socket.assigns.profile, socket.assigns.to_profile)

    {:noreply,
     socket
     |> assign(friend_status: status)}
  end

  def handle_event("jab", _, socket) do
    Profiles.send_jab(socket.assigns.from_profile, socket.assigns.to_profile)

    {:noreply,
     socket
     |> put_flash(:info, "Business Jabbed!")}
  end

  def handle_event("interact", %{"action" => action}, socket) do
    Profiles.send_interact(socket.assigns.from_profile, socket.assigns.to_profile, action)

    {:noreply,
     socket
     |> put_flash(:info, action)}
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply,
     socket |> assign(page: assigns.page + 1) |> fetch_posts(socket.assigns.show_profile)}
  end

  defp list_endorsements(id) do
    Profiles.list_endorsements(id)
  end

  defp check_between_friend_status(from, to) do
    Profiles.check_between_friend_status(from, to)
  end

  defp list_testimonials(id) do
    Profiles.list_testimonials(id)
  end

  defp get_mutual_friends(from, to) do
    Profiles.get_mutual_friends(from, to)
  end

  defp is_featured(assigns) do
    ~L"""
    <div class="inline-flex tooltip">
        <svg class="w-4 h-4 inline-flex text-yellow-500 " fill="currentColor" viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd"
                d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z"
                clip-rule="evenodd"></path>
        </svg>
        <span class="tooltip-text -mt-8">Featured Profile</span>
    </div>
    """
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end
end
