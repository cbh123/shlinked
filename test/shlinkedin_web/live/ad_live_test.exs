defmodule ShlinkedinWeb.AdLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Ads

  @create_attrs %{body: "some body", media_url: "some media_url", slug: "some slug"}
  @update_attrs %{body: "some updated body", media_url: "some updated media_url", slug: "some updated slug"}
  @invalid_attrs %{body: nil, media_url: nil, slug: nil}

  defp fixture(:ad) do
    {:ok, ad} = Ads.create_ad(@create_attrs)
    ad
  end

  defp create_ad(_) do
    ad = fixture(:ad)
    %{ad: ad}
  end

  describe "Index" do
    setup [:create_ad]

    test "lists all ads", %{conn: conn, ad: ad} do
      {:ok, _index_live, html} = live(conn, Routes.ad_index_path(conn, :index))

      assert html =~ "Listing Ads"
      assert html =~ ad.body
    end

    test "saves new ad", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.ad_index_path(conn, :index))

      assert index_live |> element("a", "New Ad") |> render_click() =~
               "New Ad"

      assert_patch(index_live, Routes.ad_index_path(conn, :new))

      assert index_live
             |> form("#ad-form", ad: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#ad-form", ad: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ad_index_path(conn, :index))

      assert html =~ "Ad created successfully"
      assert html =~ "some body"
    end

    test "updates ad in listing", %{conn: conn, ad: ad} do
      {:ok, index_live, _html} = live(conn, Routes.ad_index_path(conn, :index))

      assert index_live |> element("#ad-#{ad.id} a", "Edit") |> render_click() =~
               "Edit Ad"

      assert_patch(index_live, Routes.ad_index_path(conn, :edit, ad))

      assert index_live
             |> form("#ad-form", ad: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#ad-form", ad: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ad_index_path(conn, :index))

      assert html =~ "Ad updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes ad in listing", %{conn: conn, ad: ad} do
      {:ok, index_live, _html} = live(conn, Routes.ad_index_path(conn, :index))

      assert index_live |> element("#ad-#{ad.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#ad-#{ad.id}")
    end
  end

  describe "Show" do
    setup [:create_ad]

    test "displays ad", %{conn: conn, ad: ad} do
      {:ok, _show_live, html} = live(conn, Routes.ad_show_path(conn, :show, ad))

      assert html =~ "Show Ad"
      assert html =~ ad.body
    end

    test "updates ad within modal", %{conn: conn, ad: ad} do
      {:ok, show_live, _html} = live(conn, Routes.ad_show_path(conn, :show, ad))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ad"

      assert_patch(show_live, Routes.ad_show_path(conn, :edit, ad))

      assert show_live
             |> form("#ad-form", ad: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#ad-form", ad: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.ad_show_path(conn, :show, ad))

      assert html =~ "Ad updated successfully"
      assert html =~ "some updated body"
    end
  end
end
