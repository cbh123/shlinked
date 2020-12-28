defmodule ShlinkedinWeb.PostLive.CommentComponent do
  use ShlinkedinWeb, :live_component

  alias Shlinkedin.Timeline
  alias ShlinkedinWeb.PostLive.PostComponent

  @impl true
  def mount(socket) do
    assigns = [
      tags: [],
      search_results: [],
      current_focus: -1
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

    {:noreply, assign(socket, changeset: changeset, search_results: get_search_results(body))}
  end

  def handle_event("pick", %{"name" => name}, socket) do
    current_body = socket.assigns.changeset.changes.body
    body = String.replace(current_body, ~r/\@([^\s]*)/, "@#{name}")

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:body, body)

    {:noreply, assign(socket, changeset: changeset, search_results: [])}
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

  defp get_search_results(body) do
    case String.contains?(body, "@") do
      true ->
        query = Regex.run(~r/\@([^\s]*)/, body, capture: :all_but_first)
        Shlinkedin.Profiles.search_profiles(query)

      false ->
        []
    end
  end

  defp save_comment(%{assigns: %{profile: profile}} = socket, _, comment_params) do
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
