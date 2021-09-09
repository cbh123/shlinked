defmodule ShlinkedinWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView
  alias Shlinkedin.Accounts
  alias Shlinkedin.Profiles
  alias Shlinkedin.Profiles.Profile

  @doc """
  Renders a component inside the `ShlinkedinWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ShlinkedinWeb.HomeLive.FormComponent,
        id: @post.id || :new,
        action: @live_action,
        post: @post,
        return_to: Routes.home_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(ShlinkedinWeb.ModalComponent, modal_opts)
  end

  defmacro is_profile_view(view) do
    quote do: unquote(view) == ShlinkedinWeb.ProfileLive.Edit
  end

  def is_user(%{"user_token" => token}, %{view: view} = socket) do
    current_user = Accounts.get_user_by_session_token(token)

    case Profiles.get_profile_by_user_id(current_user.id) do
      nil when not is_profile_view(view) ->
        socket
        |> assign(current_user: current_user, profile: %Profile{})
        |> redirect(to: "/profile/welcome")

      nil ->
        socket
        |> assign(current_user: current_user, profile: %Profile{})

      profile ->
        assign(socket, current_user: current_user, profile: profile)
    end
  end

  def is_user(_params, socket) do
    assign(socket, current_user: nil, profile: %Profile{})
  end

  def check_access(socket) do
    case socket.assigns.profile.admin do
      false ->
        socket
        |> put_flash(:danger, "ACCESS DENIED")
        |> push_redirect(to: "/home")

      true ->
        socket
    end
  end
end
