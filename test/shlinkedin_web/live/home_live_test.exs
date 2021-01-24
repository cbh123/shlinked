defmodule ShlinkedinWeb.HomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Accounts

  import Shlinkedin.AccountsFixtures
  import Shlinkedin.ProfilesFixtures

  test "renders join page if user is not logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/join"}}} = live(conn, "/home")
  end

  test "initial render with user but no profile yet", %{conn: conn} do
    user = user_fixture()

    assert {:ok, view, _html} =
             conn
             |> log_in_user(user)
             |> live("/profile/welcome")
  end

  test "initial render with user and profile", %{conn: conn} do
    user = user_fixture()
    profile = profile_fixture(user)

    {:ok, view, _html} =
      conn
      |> log_in_user(user)
      |> ShlinkedinWeb.UserAuth.fetch_current_user([])
      |> live("/home")

    assert render(view) =~ "Start a post"
  end

  @profile %Profile{username: "chalie"}
  @create_attrs %{
    body: "some body"
  }
  @update_attrs %{
    body: "some updated body",
    likes_count: 43,
    reposts_count: 43,
    username: "some updated username"
  }
  @invalid_attrs %{body: nil}

  defp fixture(:post) do
    {:ok, post} = Timeline.create_post(@profile, @create_attrs)
    post
  end

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, ShlinkedinWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  defp create_post(_) do
    post = fixture(:post)
    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn, post: post, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token)

      {:ok, _index_live, html} = live(conn, Routes.home_index_path(conn, :index))

      assert html =~ post.body
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      assert index_live |> element("a", "Start a post") |> render_click() =~
               "Create Post Post"

      assert_patch(index_live, Routes.home_index_path(conn, :new))

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.home_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end
  end
end
