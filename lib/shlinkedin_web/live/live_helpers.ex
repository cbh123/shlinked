defmodule ShlinkedinWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView
  alias Shlinkedin.Accounts
  alias Shlinkedin.Accounts.Profile

  @doc """
  Renders a component inside the `ShlinkedinWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ShlinkedinWeb.PostLive.FormComponent,
        id: @post.id || :new,
        action: @live_action,
        post: @post,
        return_to: Routes.post_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, ShlinkedinWeb.ModalComponent, modal_opts)
  end

  defmacro is_profile_view(view) do
    quote do: unquote(view) == ShlinkedinWeb.ProfileLive.Edit
  end

  def is_user(%{"user_token" => token}, %{view: view} = socket) do
    current_user = Accounts.get_user_by_session_token(token)

    case Accounts.get_profile(current_user.id) do
      nil when not is_profile_view(view) ->
        socket
        |> assign(current_user: current_user, profile: %Profile{})
        |> redirect(to: "/profile/welcome")
        |> put_flash(:error, "Please finish setting up your profile!")

      nil ->
        socket
        |> assign(current_user: current_user, profile: %Profile{})

      profile ->
        assign(socket, current_user: current_user, profile: profile)
    end
  end
end
