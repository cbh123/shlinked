defmodule ShlinkedinWeb.RewardMessageLiveTest do
  use ShlinkedinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shlinkedin.TimelineFixtures

  @create_attrs %{text: "some text"}
  @update_attrs %{text: "some updated text"}
  @invalid_attrs %{text: nil}

  defp create_reward_message(_) do
    reward_message = reward_message_fixture()
    %{reward_message: reward_message}
  end

  describe "Index" do
    setup [:create_reward_message]

    test "lists all reward_messages", %{conn: conn, reward_message: reward_message} do
      {:ok, _index_live, html} = live(conn, Routes.reward_message_index_path(conn, :index))

      assert html =~ "Listing Reward messages"
      assert html =~ reward_message.text
    end

    test "saves new reward_message", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.reward_message_index_path(conn, :index))

      assert index_live |> element("a", "New Reward message") |> render_click() =~
               "New Reward message"

      assert_patch(index_live, Routes.reward_message_index_path(conn, :new))

      assert index_live
             |> form("#reward_message-form", reward_message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#reward_message-form", reward_message: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reward_message_index_path(conn, :index))

      assert html =~ "Reward message created successfully"
      assert html =~ "some text"
    end

    test "updates reward_message in listing", %{conn: conn, reward_message: reward_message} do
      {:ok, index_live, _html} = live(conn, Routes.reward_message_index_path(conn, :index))

      assert index_live |> element("#reward_message-#{reward_message.id} a", "Edit") |> render_click() =~
               "Edit Reward message"

      assert_patch(index_live, Routes.reward_message_index_path(conn, :edit, reward_message))

      assert index_live
             |> form("#reward_message-form", reward_message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#reward_message-form", reward_message: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reward_message_index_path(conn, :index))

      assert html =~ "Reward message updated successfully"
      assert html =~ "some updated text"
    end

    test "deletes reward_message in listing", %{conn: conn, reward_message: reward_message} do
      {:ok, index_live, _html} = live(conn, Routes.reward_message_index_path(conn, :index))

      assert index_live |> element("#reward_message-#{reward_message.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#reward_message-#{reward_message.id}")
    end
  end

  describe "Show" do
    setup [:create_reward_message]

    test "displays reward_message", %{conn: conn, reward_message: reward_message} do
      {:ok, _show_live, html} = live(conn, Routes.reward_message_show_path(conn, :show, reward_message))

      assert html =~ "Show Reward message"
      assert html =~ reward_message.text
    end

    test "updates reward_message within modal", %{conn: conn, reward_message: reward_message} do
      {:ok, show_live, _html} = live(conn, Routes.reward_message_show_path(conn, :show, reward_message))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Reward message"

      assert_patch(show_live, Routes.reward_message_show_path(conn, :edit, reward_message))

      assert show_live
             |> form("#reward_message-form", reward_message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#reward_message-form", reward_message: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reward_message_show_path(conn, :show, reward_message))

      assert html =~ "Reward message updated successfully"
      assert html =~ "some updated text"
    end
  end
end
