defmodule ShlinkedinWeb.SocialPromptLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shlinkedin.Timeline

  @create_attrs %{active: true, text: "some text"}
  @update_attrs %{active: false, text: "some updated text"}
  @invalid_attrs %{active: false, text: nil}

  defp fixture(:social_prompt) do
    {:ok, social_prompt} = Timeline.create_social_prompt(@create_attrs)
    social_prompt
  end

  defp create_social_prompt(_) do
    social_prompt = fixture(:social_prompt)
    %{social_prompt: social_prompt}
  end

  describe "Can't Access without being admin" do
    setup :register_user_and_profile
    setup [:create_social_prompt]

    test "rejected from index social_prompts", %{conn: conn} do
      assert {:error, _redirect} = live(conn, Routes.social_prompt_index_path(conn, :index))
    end

    test "rejected from new social_prompts", %{conn: conn} do
      assert {:error, _redirect} = live(conn, Routes.social_prompt_index_path(conn, :new))
    end

    test "rejected from edit social_prompts", %{conn: conn, social_prompt: prompt} do
      live(conn, Routes.social_prompt_index_path(conn, :edit, prompt.id))
    end
  end

  describe "Index" do
    setup :register_user_and_admin_profile
    setup [:create_social_prompt]

    test "lists all social_prompts", %{conn: conn, social_prompt: social_prompt} do
      {:ok, _index_live, html} = live(conn, Routes.social_prompt_index_path(conn, :index))

      assert html =~ "Listing Social prompts"
      assert html =~ social_prompt.text
    end

    test "saves new social_prompt", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.social_prompt_index_path(conn, :index))

      assert index_live |> element("a", "New Social prompt") |> render_click() =~
               "New Social prompt"

      assert_patch(index_live, Routes.social_prompt_index_path(conn, :new))

      assert index_live
             |> form("#social_prompt-form", social_prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#social_prompt-form", social_prompt: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.social_prompt_index_path(conn, :index))

      assert html =~ "Social prompt created successfully"
      assert html =~ "some text"
    end

    test "updates social_prompt in listing", %{conn: conn, social_prompt: social_prompt} do
      {:ok, index_live, _html} = live(conn, Routes.social_prompt_index_path(conn, :index))

      assert index_live
             |> element("#social_prompt-#{social_prompt.id} a", "Edit")
             |> render_click() =~
               "Edit Social prompt"

      assert_patch(index_live, Routes.social_prompt_index_path(conn, :edit, social_prompt))

      assert index_live
             |> form("#social_prompt-form", social_prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#social_prompt-form", social_prompt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.social_prompt_index_path(conn, :index))

      assert html =~ "Social prompt updated successfully"
      assert html =~ "some updated text"
    end

    test "deletes social_prompt in listing", %{conn: conn, social_prompt: social_prompt} do
      {:ok, index_live, _html} = live(conn, Routes.social_prompt_index_path(conn, :index))

      assert index_live
             |> element("#social_prompt-#{social_prompt.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#social_prompt-#{social_prompt.id}")
    end
  end
end
