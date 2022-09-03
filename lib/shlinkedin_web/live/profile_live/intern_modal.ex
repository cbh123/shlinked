defmodule ShlinkedinWeb.ProfileLive.InternModal do
  use ShlinkedinWeb, :live_component
  alias Shlinkedin.Interns
  alias Shlinkedin.Profiles

  def handle_event("devour", %{"intern" => id}, socket) do
    intern = Shlinkedin.Interns.get_intern!(id)
    to_profile = Profiles.get_profile_by_profile_id(intern.profile_id)

    {:ok, _intern} =
      Shlinkedin.Interns.update_intern(intern, %{"status" => "DEVOURED"})
      |> Profiles.ProfileNotifier.observer(:devoured_intern, socket.assigns.profile, to_profile)

    {:noreply,
     socket
     |> put_flash(:info, "#{intern.name} has been devoured.")
     |> push_redirect(to: Routes.profile_show_path(socket, :show, "officespider"))}
  end

  def handle_event("feed", %{"intern" => id}, socket) do
    intern = Shlinkedin.Interns.get_intern!(id)

    {:ok, _intern} =
      Shlinkedin.Interns.update_intern(intern, %{"last_fed" => NaiveDateTime.utc_now()})

    {:noreply,
     socket
     |> put_flash(:info, "#{intern.name} has been fed.")
     |> push_redirect(to: Routes.profile_show_path(socket, :show, socket.assigns.profile.slug))}
  end
end
