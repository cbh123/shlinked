defmodule ShlinkedinWeb.ProfileLive.Show do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Endorsement
  alias Shlinkedin.Profiles.Testimonial

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    show_profile = Shlinkedin.Profiles.get_profile_by_slug(slug)

    # KNOWN BUG: RIGHT WHEN YOU CREATE AN ACCOUNT, THIS BUTTON DOESN"T WORK! PROBLABLY NOT LOADED INTO SOCKET!
    socket = is_user(session, socket)

    {:ok,
     socket
     |> assign(live_action: :show)
     |> assign(show_profile: show_profile)
     |> assign(from_profile: socket.assigns.profile)
     |> assign(to_profile: show_profile)
     |> assign(friend_status: check_between_friend_status(socket.assigns.profile, show_profile))
     |> assign(endorsements: list_endorsements(show_profile.id))
     |> assign(testimonials: list_testimonials(show_profile.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :edit_endorsement, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Endorsement")
    |> assign(:endorsement, Profiles.get_endorsement!(id))
  end

  defp apply_action(socket, :edit_testimonial, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Testimonial")
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
    |> assign(:page_title, "Write a testimonial for #{socket.assigns.show_profile.persona_name}")
    |> assign(:from_profile, socket.assigns.profile)
    |> assign(:to_profile, Profiles.get_profile_by_slug(slug))
    |> assign(:testimonial, %Testimonial{})
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

  defp list_endorsements(id) do
    Profiles.list_endorsements(id)
  end

  defp check_between_friend_status(from, to) do
    Profiles.check_between_friend_status(from, to)
  end

  defp list_testimonials(id) do
    Profiles.list_testimonials(id)
  end
end
