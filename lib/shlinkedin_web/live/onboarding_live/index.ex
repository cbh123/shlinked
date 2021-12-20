defmodule ShlinkedinWeb.OnboardingLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Timeline.Generators

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
    persona_name = Shlinkedin.Timeline.Generators.full_name()
    title = @title_placeholders |> Enum.random()
    bio = @bio_placeholders |> Enum.random()
    profile = %Profile{persona_name: persona_name, persona_title: title, summary: bio}
    changeset = Profiles.change_profile(profile)

    {:ok,
     socket
     |> assign(
       step: 3,
       changeset: changeset,
       profile: profile
     )}
  end

  def handle_event("inspire", _params, socket) do
    persona_name = Shlinkedin.Timeline.Generators.full_name()
    title = @title_placeholders |> Enum.random()
    bio = @bio_placeholders |> Enum.random()

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:persona_name, persona_name)
      |> Ecto.Changeset.put_change(:persona_title, title)
      |> Ecto.Changeset.put_change(:summary, bio)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", params, socket) do
    changeset =
      Profiles.change_profile(
        socket.assigns.profile,
        params["profile"]
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"profile" => profile_params}, socket) do
    save_profile(socket, :new, profile_params)
  end

  defp save_profile(socket, :new, profile_params) do
    case(
      Profiles.create_profile(
        socket.assigns.profile,
        profile_params
      )
    ) do
      {:ok, profile} ->
        {:noreply,
         socket
         |> assign(:profile, profile)
         |> put_flash(:info, "Welcome to ShlinkedIn, #{profile.persona_name}!")
         |> redirect(to: Routes.home_index_path(socket, :index, "featured"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "changeset")
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
