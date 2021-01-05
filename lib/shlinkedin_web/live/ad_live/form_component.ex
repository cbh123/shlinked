defmodule ShlinkedinWeb.AdLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Ads
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.MediaUpload

  @impl true
  def mount(socket) do
    assigns = [
      gif_url: nil,
      gif_error: nil,
      overlay: ""
    ]

    socket = assign(socket, assigns)

    {:ok,
     allow_upload(socket, :media,
       accept: ~w(.png .jpeg .jpg .gif .mp4 .mov),
       max_entries: 1,
       external: &presign_entry/2
     )}
  end

  @impl true
  def update(%{ad: ad} = assigns, socket) do
    changeset = Ads.change_ad(ad)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def update(%{uploads: uploads}, socket) do
    socket = assign(socket, :uploads, uploads)
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"ad" => ad_params}, socket) do
    changeset =
      socket.assigns.ad
      |> Ads.change_ad(ad_params)
      |> Map.put(:action, :validate)

    case changeset.changes[:overlay] do
      nil ->
        {:noreply, assign(socket, :changeset, changeset)}

      overlay ->
        {:noreply, assign(socket, changeset: changeset, overlay: overlay)}
    end
  end

  def handle_event("save", %{"ad" => ad_params}, socket) do
    save_ad(socket, socket.assigns.action, ad_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  def handle_event("cancel-gif", _, socket) do
    {:noreply, assign(socket, :gif_url, nil)}
  end

  def handle_event("add-gif", _params, socket) do
    case socket.assigns.changeset.changes[:product] do
      nil ->
        {:noreply, assign(socket, gif_error: "Pls enter product first!")}

      body ->
        gif_url = Shlinkedin.Timeline.get_gif_from_text(body)
        {:noreply, socket |> assign(gif_url: gif_url, gif_error: nil)}
    end
  end

  defp put_photo_urls(socket, %Ad{} = ad) do
    {completed, []} = uploaded_entries(socket, :media)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}") # local path
        Path.join(MediaUpload.s3_host(), MediaUpload.s3_key(entry))
      end

    %Ad{ad | media_url: urls |> Enum.at(0)}
  end

  def consume_photos(socket, %Ad{} = ad) do
    consume_uploaded_entries(socket, :media, fn _meta, _entry -> :ok end)

    {:ok, ad}
  end

  defp save_ad(socket, :edit_ad, ad_params) do
    ad = put_photo_urls(socket, socket.assigns.ad)
    ad = %Ad{ad | gif_url: socket.assigns.gif_url}

    case Ads.update_ad(socket.assigns.profile, ad, ad_params, &consume_photos(socket, &1)) do
      {:ok, _ad} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ad updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_ad(%{assigns: %{profile: profile}} = socket, :new_ad, ad_params) do
    ad = put_photo_urls(socket, %Ad{})
    ad = %Ad{ad | gif_url: socket.assigns.gif_url}

    case Ads.create_ad(profile, ad, ad_params, &consume_photos(socket, &1)) do
      {:ok, _ad} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ad created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @bucket "shlinked"
  def s3_host, do: "//#{@bucket}.s3.amazonaws.com"
  def s3_key(entry), do: "#{entry.uuid}.#{ext(entry)}"

  def presign_entry(entry, socket) do
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
        max_file_size: uploads.media.max_file_size,
        expires_in: :timer.minutes(2)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end
