defmodule ShlinkedinWeb.ProfileLive.Edit do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Accounts
  alias Shlinkedin.Accounts.Profile

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
    socket =
      is_user(session, socket)
      |> allow_upload(:photo,
        accept: ~w(.png .jpeg .jpg .gif),
        max_entries: 1,
        external: &presign_entry/2
      )

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

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  def handle_event("validate", params, socket) do
    changeset =
      Accounts.change_profile(
        socket.assigns.profile,
        socket.assigns.current_user,
        params["profile"]
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp save_profile(socket, :edit, profile_params) do
    profile_params = put_photo_urls(socket, profile_params)

    case Accounts.update_profile(
           socket.assigns.profile,
           socket.assigns.current_user,
           profile_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Updated successfully")
         |> push_redirect(to: Routes.profile_show_path(socket, :show, profile.slug))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_profile(socket, :new, profile_params) do
    profile_params = put_photo_urls(socket, profile_params)

    case(
      Accounts.create_profile(
        socket.assigns.current_user,
        profile_params,
        &consume_photos(socket, &1)
      )
    ) do
      {:ok, profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Welcome to ShlinkedIn, #{profile.persona_name}!")
         |> push_redirect(to: Routes.post_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp put_photo_urls(socket, attrs) do
    {completed, []} = uploaded_entries(socket, :photo)

    urls =
      for entry <- completed do
        Path.join(s3_host(), s3_key(entry))
      end

    case urls do
      [] ->
        attrs

      [url | _] ->
        Map.put(attrs, "photo_url", url)
    end
  end

  @bucket "shlinked"
  defp s3_host, do: "//#{@bucket}.s3.amazonaws.com"
  defp s3_key(entry), do: "#{entry.uuid}.#{ext(entry)}"

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    key = s3_key(entry)

    config = %{
      scheme: "https://",
      host: "s3.amazonaws.com",
      region: "us-east-1",
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      Shlinkedin.SimpleS3Upload.sign_form_upload(config, @bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.photo.max_file_size,
        expires_in: :timer.minutes(2)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end

  def consume_photos(socket, %Profile{} = profile) do
    consume_uploaded_entries(socket, :photo, fn _meta, _entry -> :ok end)

    {:ok, profile}
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end
