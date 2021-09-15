defmodule ShlinkedinWeb.SocialPromptLive.Index do
  use ShlinkedinWeb, :live_view

  alias Shlinkedin.Timeline
  alias Shlinkedin.Timeline.SocialPrompt

  @impl true
  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    {:ok, socket |> check_access() |> assign(:social_prompts, list_social_prompts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Social prompt")
    |> assign(:social_prompt, Timeline.get_social_prompt!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Social prompt")
    |> assign(:social_prompt, %SocialPrompt{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Social prompts")
    |> assign(:social_prompt, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    social_prompt = Timeline.get_social_prompt!(id)
    {:ok, _} = Timeline.delete_social_prompt(social_prompt)

    {:noreply, assign(socket, :social_prompts, list_social_prompts())}
  end

  defp list_social_prompts do
    Timeline.list_social_prompts()
  end
end
