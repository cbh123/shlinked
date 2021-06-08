defmodule ShlinkedinWeb.HomeLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline

  setup :register_user_and_profile

  @create_attrs %{
    body: "some body"
  }

  test "initial render with user and profile", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> live("/home")

    assert render(view) =~ "Start a post"
  end

  describe "Index" do
    test "create new post and lists them", %{conn: conn, profile: profile} do
      {:ok, post} = Timeline.create_post(profile, @create_attrs, %Timeline.Post{})

      {:ok, _index_live, html} = live(conn, Routes.home_index_path(conn, :index))

      assert html =~ post.body
      assert html =~ "ShlinkNews"
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} =
        conn
        |> live(Routes.home_index_path(conn, :index))

      assert index_live |> element("a", "Start a post") |> render_click() =~
               "Create a post"

      assert_patch(index_live, Routes.home_index_path(conn, :new))

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.home_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end

    test "deletes post", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      assert index_live |> element("#options-menu-#{post.id}") |> render_click()

      assert index_live |> element("#post-#{post.id} a", "Delete") |> render_click()

      refute index_live
             |> element("#post-#{post.id} a", "Delete")
             |> has_element?()
    end

    # add test for comment
    test "like post", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      assert index_live |> element("#post-#{post.id}-like-Invest") |> render_click()

      assert index_live |> element("#post-likes-#{post.id}") |> render() =~ "1"
    end

    test "like post twice", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      assert Shlinkedin.Profiles.get_profile_by_profile_id(profile.id).points == %Money{
               amount: 100,
               currency: :SHLINK
             }

      assert index_live |> element("#post-#{post.id}-like-Milk") |> render_click()

      assert index_live |> element("#post-likes-#{post.id}") |> render() =~ "1 • 1 person"

      assert Shlinkedin.Profiles.get_profile_by_profile_id(profile.id).points == %Money{
               amount: 300,
               currency: :SHLINK
             }

      assert index_live |> element("#post-#{post.id}-like-Milk") |> render_click()
      assert index_live |> element("#post-likes-#{post.id}") |> render() =~ "2 • 1 person"

      assert Shlinkedin.Profiles.get_profile_by_profile_id(profile.id).points == %Money{
               amount: 300,
               currency: :SHLINK
             }
    end

    test "see likes for a post", %{conn: conn, profile: profile} do
      {:ok, view, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      view |> element("#post-#{post.id}-like-Milk") |> render_click()

      assert view |> element("#post-likes-#{post.id}") |> render() =~ "1 • 1 person"

      view
      |> element("#post-likes-#{post.id}")
      |> render_click() =~
        "Reactions"

      assert view |> render() =~ "Milk"

      {:ok, view, _html} =
        view
        |> element("##{profile.slug}")
        |> render_click()
        |> follow_redirect(conn)

      assert view |> render =~ profile.persona_name
    end

    test "write comment", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})

      # todo: figure out why this doesn't work
      # index_live
      # |> element("#new-comment-#{post.id}")
      # |> render_click()
      # |> IO.inspect(label: "rendered")

      assert index_live |> element("#first-comment-btn-#{post.id}") |> render_click() =~
               "Add a comment..."

      assert_patch(index_live, Routes.home_index_path(conn, :new_comment, post.id))

      index_live |> element("#first-comment-btn-#{post.id}") |> render_click()

      index_live
      |> form("#comment-form", comment: %{body: "yay first comment!"})
      |> render_submit()

      assert index_live |> render() =~ "yay first comment!"
      assert index_live |> render() =~ "you commented! +1 shlinkpoints"
    end

    test "like comment", %{conn: conn, profile: profile} do
      {:ok, view, _html} = live(conn, Routes.home_index_path(conn, :index))

      {:ok, post} = Timeline.create_post(profile, %{body: "test"}, %Timeline.Post{})
      {:ok, post} = Timeline.create_comment(profile, post, %{body: "yay first comment!"})

      comment = post.comments |> Enum.at(0)

      assert view |> render() =~ "yay first comment!"

      assert view |> element("#comment-#{comment.id}-like-btn-Slap") |> render_click() =~ "1"
      assert view |> element("#comment-#{comment.id}-like-btn-Warm") |> render_click() =~ "2"
      assert view |> element("#comment-#{comment.id}-like-btn-Slap") |> render_click() =~ "3"

      assert view |> element("#show-comment-#{post.id}-likes") |> render_click() =~
               "Comment Reactions"
    end
  end
end
