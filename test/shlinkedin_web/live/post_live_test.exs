defmodule ShlinkedinWeb.PostLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline

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
    {:ok, post} = Timeline.create_post(@create_attrs)
    post
  end

  defp create_post(_) do
    post = fixture(:post)
    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Listing Posts"
      assert html =~ post.body
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, Routes.post_index_path(conn, :new))

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end

    test "deletes post in listing", %{conn: conn, post: post} do
      {:ok, index_live, html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("#post-#{post.id} a", "Delete") |> render_click()
      assert html =~ "hidden"
    end
  end
end
