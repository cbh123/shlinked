defmodule Shlinkedin.ProfilesTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Profiles

  describe "endorsements" do
    alias Shlinkedin.Profiles.Endorsement

    @valid_attrs %{body: "some body", emoji: "some emoji", gif_url: "some gif_url"}
    @update_attrs %{body: "some updated body", emoji: "some updated emoji", gif_url: "some updated gif_url"}
    @invalid_attrs %{body: nil, emoji: nil, gif_url: nil}

    def endorsement_fixture(attrs \\ %{}) do
      {:ok, endorsement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profiles.create_endorsement()

      endorsement
    end

    test "list_endorsements/0 returns all endorsements" do
      endorsement = endorsement_fixture()
      assert Profiles.list_endorsements() == [endorsement]
    end

    test "get_endorsement!/1 returns the endorsement with given id" do
      endorsement = endorsement_fixture()
      assert Profiles.get_endorsement!(endorsement.id) == endorsement
    end

    test "create_endorsement/1 with valid data creates a endorsement" do
      assert {:ok, %Endorsement{} = endorsement} = Profiles.create_endorsement(@valid_attrs)
      assert endorsement.body == "some body"
      assert endorsement.emoji == "some emoji"
      assert endorsement.gif_url == "some gif_url"
    end

    test "create_endorsement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_endorsement(@invalid_attrs)
    end

    test "update_endorsement/2 with valid data updates the endorsement" do
      endorsement = endorsement_fixture()
      assert {:ok, %Endorsement{} = endorsement} = Profiles.update_endorsement(endorsement, @update_attrs)
      assert endorsement.body == "some updated body"
      assert endorsement.emoji == "some updated emoji"
      assert endorsement.gif_url == "some updated gif_url"
    end

    test "update_endorsement/2 with invalid data returns error changeset" do
      endorsement = endorsement_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_endorsement(endorsement, @invalid_attrs)
      assert endorsement == Profiles.get_endorsement!(endorsement.id)
    end

    test "delete_endorsement/1 deletes the endorsement" do
      endorsement = endorsement_fixture()
      assert {:ok, %Endorsement{}} = Profiles.delete_endorsement(endorsement)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_endorsement!(endorsement.id) end
    end

    test "change_endorsement/1 returns a endorsement changeset" do
      endorsement = endorsement_fixture()
      assert %Ecto.Changeset{} = Profiles.change_endorsement(endorsement)
    end
  end
end
