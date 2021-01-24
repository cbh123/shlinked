defmodule ShlinkedinWeb.HomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline
  alias Shlinkedin.Accounts

  import Shlinkedin.AccountsFixtures
  import Shlinkedin.ProfilesFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, ShlinkedinWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    user = user_fixture()

    %{user: user, profile: profile_fixture(user), conn: conn}
  end

  test "renders join page if user is not logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/join"}}} = live(conn, "/home")
  end

  test "initial render with user but no profile yet", %{conn: conn} do
    user = user_fixture()

    assert {:ok, _view, _html} =
             conn
             |> log_in_user(user)
             |> live("/profile/welcome")
  end

  test "initial render with user and profile", %{conn: conn} do
    user = user_fixture()
    profile_fixture(user)

    {:ok, view, _html} =
      conn
      |> log_in_user(user)
      |> ShlinkedinWeb.UserAuth.fetch_current_user([])
      |> live("/home")

    assert render(view) =~ "Start a post"
  end

  @create_attrs %{
    body: "some body"
  }

  describe "Index" do
    test "lists all posts", %{conn: conn, user: user, profile: profile} do
      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      user_token = Accounts.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token)

      {:ok, _index_live, html} = live(conn, Routes.home_index_path(conn, :index))

      assert html =~ post.body
    end

    test "saves new post", %{conn: conn, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> ShlinkedinWeb.UserAuth.fetch_current_user([])
        |> live(Routes.home_index_path(conn, :index))

      assert index_live |> element("a", "Start a post") |> render_click() =~
               "Create a post"

      assert_patch(index_live, Routes.home_index_path(conn, :new))

      {:ok, _, html} =
        index_live
        |> IO.inspect()
        |> form("#post-form", post: @create_attrs)
        |> IO.inspect()
        |> render_submit()
        |> IO.inspect()

      # |> follow_redirect(conn, Routes.home_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end
  end
end
