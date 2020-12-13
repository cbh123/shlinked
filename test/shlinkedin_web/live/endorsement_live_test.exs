defmodule ShlinkedinWeb.EndorsementLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Profiles

  @create_attrs %{body: "some body", emoji: "some emoji", gif_url: "some gif_url"}
  @update_attrs %{body: "some updated body", emoji: "some updated emoji", gif_url: "some updated gif_url"}
  @invalid_attrs %{body: nil, emoji: nil, gif_url: nil}

  defp fixture(:endorsement) do
    {:ok, endorsement} = Profiles.create_endorsement(@create_attrs)
    endorsement
  end

  defp create_endorsement(_) do
    endorsement = fixture(:endorsement)
    %{endorsement: endorsement}
  end

  describe "Index" do
    setup [:create_endorsement]

    test "lists all endorsements", %{conn: conn, endorsement: endorsement} do
      {:ok, _index_live, html} = live(conn, Routes.endorsement_index_path(conn, :index))

      assert html =~ "Listing Endorsements"
      assert html =~ endorsement.body
    end

    test "saves new endorsement", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.endorsement_index_path(conn, :index))

      assert index_live |> element("a", "New Endorsement") |> render_click() =~
               "New Endorsement"

      assert_patch(index_live, Routes.endorsement_index_path(conn, :new))

      assert index_live
             |> form("#endorsement-form", endorsement: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#endorsement-form", endorsement: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.endorsement_index_path(conn, :index))

      assert html =~ "Endorsement created successfully"
      assert html =~ "some body"
    end

    test "updates endorsement in listing", %{conn: conn, endorsement: endorsement} do
      {:ok, index_live, _html} = live(conn, Routes.endorsement_index_path(conn, :index))

      assert index_live |> element("#endorsement-#{endorsement.id} a", "Edit") |> render_click() =~
               "Edit Endorsement"

      assert_patch(index_live, Routes.endorsement_index_path(conn, :edit, endorsement))

      assert index_live
             |> form("#endorsement-form", endorsement: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#endorsement-form", endorsement: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.endorsement_index_path(conn, :index))

      assert html =~ "Endorsement updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes endorsement in listing", %{conn: conn, endorsement: endorsement} do
      {:ok, index_live, _html} = live(conn, Routes.endorsement_index_path(conn, :index))

      assert index_live |> element("#endorsement-#{endorsement.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#endorsement-#{endorsement.id}")
    end
  end

  describe "Show" do
    setup [:create_endorsement]

    test "displays endorsement", %{conn: conn, endorsement: endorsement} do
      {:ok, _show_live, html} = live(conn, Routes.endorsement_show_path(conn, :show, endorsement))

      assert html =~ "Show Endorsement"
      assert html =~ endorsement.body
    end

    test "updates endorsement within modal", %{conn: conn, endorsement: endorsement} do
      {:ok, show_live, _html} = live(conn, Routes.endorsement_show_path(conn, :show, endorsement))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Endorsement"

      assert_patch(show_live, Routes.endorsement_show_path(conn, :edit, endorsement))

      assert show_live
             |> form("#endorsement-form", endorsement: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#endorsement-form", endorsement: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.endorsement_show_path(conn, :show, endorsement))

      assert html =~ "Endorsement updated successfully"
      assert html =~ "some updated body"
    end
  end
end
