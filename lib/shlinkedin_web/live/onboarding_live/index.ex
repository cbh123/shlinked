defmodule ShlinkedinWeb.OnboardingLive.Index do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Timeline.Generators

  def mount(_params, _session, socket) do
    persona_name = generate_name()
    title = generate_title()
    profile = %Profile{persona_name: persona_name, persona_title: title}
    changeset = Profiles.change_profile(profile)

    {:ok,
     socket
     |> assign(
       changeset: changeset,
       profile: profile,
       profile_created: true,
       body: "",
       gif_url: nil
     )}
  end

  def handle_event("adversity", _, socket) do
    {:noreply, assign(socket, body: Generators.adversity())}
  end

  def handle_event("job", _, socket) do
    {:noreply, assign(socket, body: Generators.job())}
  end

  def handle_event("challenge", _, socket) do
    {:noreply, assign(socket, body: Generators.business_challenge())}
  end

  def handle_event("strange", _, socket) do
    {:noreply, assign(socket, body: Generators.strange_observation())}
  end

  def handle_event("guilt", _, socket) do
    {:noreply, assign(socket, body: Generators.guilt_trip())}
  end

  def handle_event("inspire", _params, socket) do
    persona_name = generate_name()
    title = generate_title()

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:persona_name, persona_name)
      |> Ecto.Changeset.put_change(:persona_title, title)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("hashtags", _, socket) do
    socket = assign(socket, body: socket.assigns.body <> Generators.hashtags())
    {:noreply, socket}
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

  def handle_event("store", %{"profile" => profile_params}, socket) do
    persona_name = socket.assigns.profile.persona_name

    username =
      "#{persona_name |> String.slice(0..5)}#{:rand.uniform(100_000)}" |> String.downcase()

    require IEx
    IEx.pry()
    {:noreply, socket |> assign(username: username)}
  end

  def handle_event("save", %{"profile" => profile_params}, socket) do
    persona_name = socket.assigns.profile.persona_name

    username =
      "#{persona_name |> String.slice(0..5)}#{:rand.uniform(100_000)}"
      |> String.downcase()
      |> Generators.slugify()

    profile_params =
      profile_params
      |> Map.put("username", username)
      |> Map.put("slug", username)

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
        {:noreply, socket |> assign(profile: profile, profile_created: true)}

      # {:noreply,
      #  socket
      #  |> assign(:profile, profile)
      #  |> put_flash(:info, "Welcome to ShlinkedIn, #{profile.persona_name}!")
      #  |> redirect(to: Routes.home_index_path(socket, :index, "featured"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "changset")
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp generate_name() do
    Generators.full_name()
  end

  defp generate_title() do
    Generators.present_title() |> capitalize_first_letter()
  end

  defp capitalize_first_letter(string) do
    {first, rest} = string |> String.next_grapheme()
    String.upcase(first) <> rest
  end
end
