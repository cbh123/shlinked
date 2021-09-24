defmodule Shlinkedin.ModeratingTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Moderating

  describe "moderators" do
    alias Shlinkedin.Moderating.Moderator

    @valid_attrs %{moderator_class: "some moderator_class"}
    @update_attrs %{moderator_class: "some updated moderator_class"}
    @invalid_attrs %{moderator_class: nil}

    def moderator_fixture(attrs \\ %{}) do
      {:ok, moderator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Moderating.create_moderator()

      moderator
    end

    test "list_moderators/0 returns all moderators" do
      moderator = moderator_fixture()
      assert Moderating.list_moderators() == [moderator]
    end

    test "get_moderator!/1 returns the moderator with given id" do
      moderator = moderator_fixture()
      assert Moderating.get_moderator!(moderator.id) == moderator
    end

    test "create_moderator/1 with valid data creates a moderator" do
      assert {:ok, %Moderator{} = moderator} = Moderating.create_moderator(@valid_attrs)
      assert moderator.moderator_class == "some moderator_class"
    end

    test "create_moderator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Moderating.create_moderator(@invalid_attrs)
    end

    test "update_moderator/2 with valid data updates the moderator" do
      moderator = moderator_fixture()
      assert {:ok, %Moderator{} = moderator} = Moderating.update_moderator(moderator, @update_attrs)
      assert moderator.moderator_class == "some updated moderator_class"
    end

    test "update_moderator/2 with invalid data returns error changeset" do
      moderator = moderator_fixture()
      assert {:error, %Ecto.Changeset{}} = Moderating.update_moderator(moderator, @invalid_attrs)
      assert moderator == Moderating.get_moderator!(moderator.id)
    end

    test "delete_moderator/1 deletes the moderator" do
      moderator = moderator_fixture()
      assert {:ok, %Moderator{}} = Moderating.delete_moderator(moderator)
      assert_raise Ecto.NoResultsError, fn -> Moderating.get_moderator!(moderator.id) end
    end

    test "change_moderator/1 returns a moderator changeset" do
      moderator = moderator_fixture()
      assert %Ecto.Changeset{} = Moderating.change_moderator(moderator)
    end
  end
end
