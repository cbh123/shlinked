defmodule ShlinkedinWeb.ProfileLive.Edit do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Accounts

  @bio_placeholders [
    "My approach to business is simple: work hard at something everyday of your life and when you die you will have worked very hard and are a good boy! Then you get to eat all the marzipan your precious little heart could ever desire. Also, my cousin was on a flight next to Richard Branson once.",
    "At age five, Gary Vaynerchuck became an entrepreneur by selling lemonade and baseball cards at local malls. I’m proud to have started selling lemonade in the Walmart parking lot at age 34—my entrepreneurial journey is just starting to froth up, and I’m eager to show the world that entrepreneur doesn’t just mean someone who is kind of stupid and wants to start a business.",
    "To me, sales is an art form. It requires creativity, and tact, to nurture leads and close deals. My brush? My rolodex. My canvas? Also my rolodex. Here are other things that I think are art: scraping gum from the underside of diner tables without leaving behind little bits of the gum, spreadsheets, putting quirky stickers on my laptop, nalgene collecting.",
    "To get ahead in the world of business, you’ve got to be ready to leave things behind. Preconceptions about other people, misgivings about yourself, tough times, children/spouses, mistakes you’ve made, an old car, shoes—whatever it takes. I’m willing to do that. And if you’re looking for someone with 18 years of sales and marketing experience you’ve found him. If it helps, I don’t speak with my children so they won’t be an issue."
  ]

  @title_placeholders [
    "Stephon is my name, and optimizing workflows is my game.",
    "I’m here to chew gum and qualify leads—and I’m all out of gum.",
    "Don’t blink, lest I steal your clients.",
    "I’ve been sales managing for going on 20 years and my children don’t respect me.",
    "Two hot children in a trenchcoat running a fortune 500 company."
  ]

  def mount(_params, session, socket) do
    socket = is_user(session, socket)

    changeset = Accounts.change_profile(socket.assigns.profile, socket.assigns.current_user)

    {:ok,
     socket
     |> assign(changeset: changeset)
     |> assign(bio_placeholder: @bio_placeholders |> Enum.random())
     |> assign(title_placeholder: @title_placeholders |> Enum.random())}
  end

  def handle_event("save", %{"profile" => profile_params}, socket) do
    save_profile(socket, socket.assigns.live_action, profile_params)
  end

  def handle_event("validate", params, socket) do
    changeset =
      Accounts.change_profile(
        socket.assigns.profile,
        socket.assigns.current_user,
        params["profile"]
      )
      |> Map.put(:action, :validate)

    IO.inspect(changeset, label: "")
    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp save_profile(socket, :edit, profile_params) do
    case Accounts.update_profile(
           socket.assigns.profile,
           socket.assigns.current_user,
           profile_params
         ) do
      {:ok, profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: Routes.profile_show_path(socket, :show, profile.slug))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
