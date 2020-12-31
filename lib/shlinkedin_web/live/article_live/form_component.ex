defmodule ShlinkedinWeb.ArticleLive.FormComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.News
  alias Shlinkedin.News.Article

  @impl true
  def mount(socket) do
    socket = socket |> assign(gif_url: nil, gif_error: nil)

    {:ok,
     allow_upload(socket, :media,
       accept: ~w(.png .jpeg .jpg .gif .mp4 .mov),
       max_entries: 1,
       external: &presign_entry/2
     )}
  end

  @impl true
  def update(%{article: article} = assigns, socket) do
    changeset = News.change_article(article)

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
  def handle_event("validate", %{"article" => article_params}, socket) do
    changeset =
      socket.assigns.article
      |> News.change_article(article_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"article" => article_params}, socket) do
    save_article(socket, socket.assigns.action, article_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  defp save_article(%{assigns: %{profile: profile}} = socket, :new_article, article_params) do
    article = put_photo_urls(socket, %Article{})

    case News.create_article(
           profile,
           article,
           article_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp put_photo_urls(socket, %Article{} = article) do
    {completed, []} = uploaded_entries(socket, :media)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}") # local path
        Path.join(s3_host(), s3_key(entry))
      end

    %Article{article | media_url: urls |> Enum.at(0)}
  end

  def consume_photos(socket, %News.Article{} = article) do
    consume_uploaded_entries(socket, :media, fn _meta, _entry -> :ok end)

    {:ok, article}
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
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
        max_file_size: uploads.media.max_file_size,
        expires_in: :timer.minutes(2)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end
end
