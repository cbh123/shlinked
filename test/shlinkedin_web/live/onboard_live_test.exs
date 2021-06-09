defmodule ShlinkedinWeb.OnboardLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.AccountsFixtures

  test "creates account and logs the user in", %{conn: conn} do
    email = unique_user_email()

    conn =
      post(conn, Routes.user_registration_path(conn, :create), %{
        "user" => %{"email" => email, "password" => valid_user_password()}
      })

    assert get_session(conn, :user_token)
    assert redirected_to(conn) =~ "/"

    # Now do a logged in request and assert on the menu
    conn = get(conn, "/")
    response = html_response(conn, 302)

    assert response =~
             "<html><body>You are being <a href=\"/profile/welcome\">redirected</a>.</body></html>"

    # welcome page
    {:ok, view, _html} =
      conn
      |> live("/profile/welcome")

    assert view |> render() =~ "Welcome to ShlinkedIn!"

    # blank real name, so error
    assert view
           |> form("#profile-form", profile: %{persona_name: "Charlie B", real_name: ""})
           |> render_submit() =~
             "can&apos;t be blank"

    # success!
    {:ok, conn} =
      view
      |> form("#profile-form", profile: %{persona_name: "Charlie B", real_name: "Charlifer"})
      |> render_submit()
      |> follow_redirect(conn, "/home%3Ftype%3Dfeatured")

    # make sure backend profile is actually right
    user = Shlinkedin.Accounts.get_user_by_email(email)
    profile = Shlinkedin.Profiles.get_profile_by_user_id(user.id)
    assert profile.persona_name == "Charlie B"
    assert profile.real_name == "Charlifer"

    assert html_response(conn, 200) =~ "Welcome to ShlinkedIn, Charlie B"
    assert html_response(conn, 200) =~ "Unpaid Intern"
    assert html_response(conn, 200) =~ "Dinks"
  end
end
