defmodule ShlinkedinWeb.OnboardingLive.CreateUser do
  use ShlinkedinWeb, :live_view
  alias Shlinkedin.Accounts
  alias Shlinkedin.Accounts.User
  alias ShlinkedinWeb.UserAuth

  def mount(_params, session, socket) do
    socket = is_user(session, socket)
    changeset = Accounts.change_user_registration(%User{})

    {:ok,
     socket
     |> assign(changeset: changeset)}
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
