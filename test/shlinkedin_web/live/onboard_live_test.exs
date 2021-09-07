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
           |> form("#profile-form", profile: %{persona_name: "Charlie B"})
           |> render_submit() =~
             "can&#39;t be blank"

    assert view
           |> form("#profile-form",
             profile: %{persona_name: "Charlie B", username: "@charlie"}
           )
           |> render_submit() =~
             "invalid username - no special characters pls!"

    # success!
    {:ok, conn} =
      view
      |> form("#profile-form",
        profile: %{persona_name: "Charlie B", username: "charlie"}
      )
      |> render_submit()
      |> follow_redirect(conn, "/home%3Ftype%3Dfeatured")

    # make sure backend profile is actually right
    user = Shlinkedin.Accounts.get_user_by_email(email)
    profile = Shlinkedin.Profiles.get_profile_by_user_id(user.id)
    assert profile.persona_name == "Charlie B"
    assert profile.username == "charlie"
    assert profile.slug == "charlie"

    assert html_response(conn, 200) =~ "Welcome to ShlinkedIn, Charlie B"
    assert html_response(conn, 200) =~ "Unpaid Intern"
    assert html_response(conn, 200) =~ "Dinks"
  end

  test "creates account with generator and logs the user in", %{conn: conn} do
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

    # uses the inspire me button
    view |> element("#inspire") |> render_click()

    # success!
    {:ok, conn} =
      view
      |> form("#profile-form",
        profile: %{}
      )
      |> render_submit()
      |> follow_redirect(conn, "/home%3Ftype%3Dfeatured")

    # make sure backend profile is actually right
    user = Shlinkedin.Accounts.get_user_by_email(email)
    profile = Shlinkedin.Profiles.get_profile_by_user_id(user.id)
    assert profile.persona_name != nil
    assert profile.username != nil
    assert profile.slug == profile.username

    assert profile.photo_url !=
             "https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/George_Washington%2C_1776.jpg/1200px-George_Washington%2C_1776.jpg"

    assert(html_response(conn, 200) =~ "Welcome to ShlinkedIn, #{profile.persona_name}")
    assert html_response(conn, 200) =~ "Unpaid Intern"
    assert html_response(conn, 200) =~ "Dinks"
  end

  describe "2nd step" do
    setup :register_and_log_in_user

    test "creates account and logs the user in 2", %{conn: conn} do
      {:ok, _view} = conn |> live("/") |> follow_redirect(conn)
    end
  end
end
