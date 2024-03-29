defmodule Shlinkedin.ModerationTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Moderation
  import Shlinkedin.ProfilesFixtures
  import Shlinkedin.TimelineFixtures

  describe "mod_action" do
    alias Shlinkedin.Moderation.Action

    @valid_attrs %{reason: "reason", action: "some action"}
    @update_attrs %{action: "some updated action", reason: "new reason"}
    @invalid_attrs %{action: nil}

    def action_fixture(attrs \\ %{}) do
      profile = profile_fixture()
      post = post_fixture()

      {:ok, action} =
        Moderation.create_action(
          post,
          profile,
          attrs
          |> Enum.into(@valid_attrs)
        )

      action
    end

    test "create_action/1 with valid data creates a action" do
      assert {:ok, %Action{} = action} =
               Moderation.create_action(post_fixture(), profile_fixture(), @valid_attrs)

      assert action.action == "some action"
      assert action.reason == "reason"
    end

    test "create_action/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Moderation.create_action(post_fixture(), profile_fixture(), @invalid_attrs)
    end

    test "update_action/2 with valid data updates the action" do
      action = action_fixture()
      assert {:ok, %Action{} = action} = Moderation.update_action(action, @update_attrs)
      assert action.action == "some updated action"
      assert action.reason == "new reason"
    end

    test "update_action/2 with invalid data returns error changeset" do
      action = action_fixture()
      assert {:error, %Ecto.Changeset{}} = Moderation.update_action(action, @invalid_attrs)
    end
  end
end
