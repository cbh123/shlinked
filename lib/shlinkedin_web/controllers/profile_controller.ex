defmodule ShlinkedinWeb.ProfileController do
  use ShlinkedinWeb, :controller
  alias Shlinkedin.Accounts
  alias Shlinkedin.Accounts.Profile

  def new(conn, _params) do
    user = conn.assigns.current_user

    # Only want people to go to this page if they haven't made a username yet
    case Accounts.get_profile(user.id) do
      nil ->
        changeset = Accounts.change_profile(%Profile{}, user)
        render(conn, "new.html", changeset: changeset)

      _ ->
        conn
        |> redirect(to: Routes.profile_edit_path(conn, :new))
    end
  end

  def create(conn, %{"profile" => profile}) do
    case Accounts.create_profile(conn.assigns.current_user, profile) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Username saved successfully.")
        |> redirect(to: Routes.profile_edit_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
