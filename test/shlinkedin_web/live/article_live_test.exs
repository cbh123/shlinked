defmodule ShlinkedinWeb.ArticleLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.News

  @create_attrs %{headline: "some headline", media_url: "some media_url", slug: "some slug"}
  @update_attrs %{headline: "some updated headline", media_url: "some updated media_url", slug: "some updated slug"}
  @invalid_attrs %{headline: nil, media_url: nil, slug: nil}

  defp fixture(:article) do
    {:ok, article} = News.create_article(@create_attrs)
    article
  end

  defp create_article(_) do
    article = fixture(:article)
    %{article: article}
  end

  describe "Index" do
    setup [:create_article]

    test "lists all articles", %{conn: conn, article: article} do
      {:ok, _index_live, html} = live(conn, Routes.article_index_path(conn, :index))

      assert html =~ "Listing Articles"
      assert html =~ article.headline
    end

    test "saves new article", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      assert index_live |> element("a", "New Article") |> render_click() =~
               "New Article"

      assert_patch(index_live, Routes.article_index_path(conn, :new))

      assert index_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#article-form", article: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.article_index_path(conn, :index))

      assert html =~ "Article created successfully"
      assert html =~ "some headline"
    end

    test "updates article in listing", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      assert index_live |> element("#article-#{article.id} a", "Edit") |> render_click() =~
               "Edit Article"

      assert_patch(index_live, Routes.article_index_path(conn, :edit, article))

      assert index_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#article-form", article: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.article_index_path(conn, :index))

      assert html =~ "Article updated successfully"
      assert html =~ "some updated headline"
    end

    test "deletes article in listing", %{conn: conn, article: article} do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      assert index_live |> element("#article-#{article.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#article-#{article.id}")
    end
  end

  describe "Show" do
    setup [:create_article]

    test "displays article", %{conn: conn, article: article} do
      {:ok, _show_live, html} = live(conn, Routes.article_show_path(conn, :show, article))

      assert html =~ "Show Article"
      assert html =~ article.headline
    end

    test "updates article within modal", %{conn: conn, article: article} do
      {:ok, show_live, _html} = live(conn, Routes.article_show_path(conn, :show, article))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Article"

      assert_patch(show_live, Routes.article_show_path(conn, :edit, article))

      assert show_live
             |> form("#article-form", article: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#article-form", article: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.article_show_path(conn, :show, article))

      assert html =~ "Article updated successfully"
      assert html =~ "some updated headline"
    end
  end
end
