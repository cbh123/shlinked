defmodule ShlinkedinWeb.PostLive.CommentComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline
  alias ShlinkedinWeb.PostLive.PostComponent

  @impl true
  def mount(socket) do
    assigns = [
      tags: [],
      search_results: [],
      current_focus: -1,
      tagging_mode: false,
      query: ""
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def update(%{comment: comment} = assigns, socket) do
    changeset = Timeline.change_comment(comment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def update(info, socket) do
    {:ok,
     socket
     |> assign(:progress, info.progress)
     |> assign(:loading_text, info.loading_text)}
  end

  @impl true
  def handle_event("validate", %{"comment" => comment_params}, socket) do
    body = comment_params["body"]

    changeset =
      socket.assigns.comment
      |> Timeline.change_comment(comment_params)
      |> Map.put(:action, :validate)

    new_tagging_mode = check_tagging_mode(body, socket.assigns.tagging_mode)

    {:noreply,
     assign(socket,
       changeset: changeset,
       tagging_mode: new_tagging_mode,
       query: add_to_query(new_tagging_mode, body),
       search_results: get_search_results(new_tagging_mode, socket.assigns.query)
     )}
  end

  def handle_event("pick", %{"name" => username}, socket) do
    body = socket.assigns.changeset.changes.body
    sliced_body = String.replace(body, String.split(body, "@") |> List.last(), "")
    new_body = sliced_body <> username <> " "

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:body, new_body)

    {:noreply,
     assign(socket,
       changeset: changeset,
       search_results: [],
       tags: socket.assigns.tags ++ [username]
     )}
  end

  def handle_event("remove-tag", %{"name" => username}, %{assigns: %{tags: tags}} = socket) do
    current_body = socket.assigns.changeset.changes.body

    new_body = String.replace(current_body, "@#{username}", "")

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:body, new_body)

    socket = assign(socket, tags: List.delete(tags, username), changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("comment-ai", _, socket) do
    send_update_after(
      ShlinkedinWeb.PostLive.CommentComponent,
      [id: :new_comment, loading_text: Timeline.comment_loading(), progress: 33],
      500
    )

    send_update_after(
      ShlinkedinWeb.PostLive.CommentComponent,
      [id: :new_comment, loading_text: Timeline.comment_loading(), progress: 66],
      800
    )

    send_update_after(
      ShlinkedinWeb.PostLive.CommentComponent,
      [id: :new_comment, loading_text: Timeline.comment_loading(), progress: 99],
      1250
    )

    send_update_after(
      ShlinkedinWeb.PostLive.CommentComponent,
      [id: :new_comment, loading_text: "Comment generated", progress: 100, ai_loading: false],
      1750
    )

    send_update_after(
      ShlinkedinWeb.PostLive.CommentComponent,
      [id: :new_comment, comment: %Timeline.Comment{body: Timeline.comment_ai()}],
      1800
    )

    {:noreply,
     socket
     |> assign(:progress, 5)
     |> assign(:ai_loading, !socket.assigns.ai_loading)
     |> assign(:loading_text, Timeline.comment_loading())}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    save_comment(socket, socket.assigns.action, comment_params)
  end

  defp check_tagging_mode(body, current_mode) do
    case body |> String.last() do
      "@" -> true
      " " -> false
      _ -> current_mode
    end
  end

  defp add_to_query(current_mode, body) do
    case current_mode do
      true ->
        String.split(body, "@") |> List.last()

      false ->
        ""
    end
  end

  defp get_search_results(current_mode, query) do
    if current_mode == true, do: Shlinkedin.Profiles.search_profiles(query), else: []
  end

  defp save_comment(%{assigns: %{profile: profile, tags: tags}} = socket, _, comment_params) do
    comment_params = Map.put(comment_params, "profile_tags", tags)

    case Timeline.create_comment(profile, socket.assigns.post, comment_params) do
      {:ok, _comment} ->
        send_update(PostComponent,
          id: socket.assigns.post.id,
          comment_spin: true,
          # hardcoded
          num_show_comments: 100
        )

        send_update_after(
          PostComponent,
          [id: socket.assigns.post.id, comment_spin: false],
          1000
        )

        {:noreply,
         socket
         |> put_flash(:info, "you commented! +1 shlink points")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
