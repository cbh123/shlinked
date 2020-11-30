defmodule ShlinkedinWeb.ProfileController do
  use ShlinkedinWeb, :controller
  alias Shlinkedin.Accounts
  alias Shlinkedin.Accounts.Profile

  def new(conn, _params) do
    user = conn.assigns.current_user

    case Accounts.get_profile(user.id) do
      nil ->
        changeset = Accounts.change_profile(%Profile{}, user)
        render(conn, "new.html", changeset: changeset)

      _ ->
        conn
        |> redirect(to: Routes.profile_path(conn, :edit))
    end
  end

  def create(conn, %{"profile" => profile}) do
    case Accounts.create_profile(conn.assigns.current_user, profile) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Username saved successfully.")
        |> redirect(to: Routes.profile_path(conn, :edit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user

    case Accounts.get_profile(user.id) do
      nil ->
        conn
        |> redirect(to: Routes.profile_path(conn, :new))

      profile ->
        changeset = Accounts.change_profile(profile, user)
        render(conn, "edit.html", changeset: changeset, profile: profile)
    end
  end

  def update(conn, %{"profile" => profile_params}) do
    user = conn.assigns.current_user
    profile = Accounts.get_profile(user.id)

    case Accounts.update_profile(profile, user, profile_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Profile updated successfully")
        |> redirect(to: Routes.post_index_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, profile: profile)
    end
  end
end
