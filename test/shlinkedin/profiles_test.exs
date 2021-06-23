defmodule Shlinkedin.ProfilesTest do
  use Shlinkedin.DataCase
  import Shlinkedin.ProfilesFixtures
  import Shlinkedin.AccountsFixtures
  alias Shlinkedin.Profiles

  describe "endorsements" do
    alias Shlinkedin.Profiles.Endorsement
    alias Shlinkedin.Profiles.Profile

    @valid_attrs %{body: "some body", emoji: "some emoji", gif_url: "some gif_url"}
    @update_attrs %{
      body: "some updated body",
      emoji: "some updated emoji",
      gif_url: "some updated gif_url"
    }
    @invalid_attrs %{body: nil, emoji: nil, gif_url: nil}

    def endorsement_fixture(from, to, attrs \\ %{}) do
      {:ok, endorsement} = Profiles.create_endorsement(from, to, attrs |> Enum.into(@valid_attrs))

      endorsement
    end

    setup do
      from = profile_fixture()
      to = profile_fixture()
      user = user_fixture()
      %{from: from, to: to, user: user}
    end

    test "create_profile", %{user: user} do
      assert {:ok, %Profile{} = profile} =
               Profiles.create_profile(user, %{
                 "persona_name" => "Charlie H",
                 "username" => "charlop"
               })

      assert profile.persona_name == "Charlie H"
      assert profile.user_id == user.id
      assert profile.slug == "charlop"
      assert profile.username == "charlop"
    end

    test "list_endorsements/1 returns all endorsements for that profile", %{from: from, to: to} do
      endorsement = endorsement_fixture(from, to)
      assert Profiles.list_endorsements(to.id) == [endorsement]
    end

    test "get_endorsement!/1 returns the endorsement with given id", %{from: from, to: to} do
      endorsement = endorsement_fixture(from, to)
      assert Profiles.get_endorsement!(endorsement.id) == endorsement

      # test that notifications come up
      notification =
        Profiles.list_notifications(to.id, 1)
        |> Enum.at(0)

      assert notification.action == "endorsed you for"
      assert notification.from_profile_id == from.id
      # todo: uncomments
      # assert to.points == 400
    end

    test "create_endorsement/1 with valid data creates a endorsement", %{from: from, to: to} do
      assert {:ok, %Endorsement{} = endorsement} =
               Profiles.create_endorsement(from, to, @valid_attrs)

      assert endorsement.body == "some body"
      assert endorsement.emoji == "some emoji"
      assert endorsement.gif_url == "some gif_url"
    end

    test "create_endorsement/1 with invalid data returns error changeset", %{from: from, to: to} do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_endorsement(from, to, @invalid_attrs)
    end

    test "update_endorsement/2 with valid data updates the endorsement", %{from: from, to: to} do
      endorsement = endorsement_fixture(from, to)

      assert {:ok, %Endorsement{} = endorsement} =
               Profiles.update_endorsement(endorsement, @update_attrs)

      assert endorsement.body == "some updated body"
      assert endorsement.emoji == "some updated emoji"
      assert endorsement.gif_url == "some updated gif_url"
    end

    test "update_endorsement/2 with invalid data returns error changeset", %{from: from, to: to} do
      endorsement = endorsement_fixture(from, to)

      assert {:error, %Ecto.Changeset{}} =
               Profiles.update_endorsement(endorsement, @invalid_attrs)

      assert endorsement == Profiles.get_endorsement!(endorsement.id)
    end

    test "delete_endorsement/1 deletes the endorsement", %{from: from, to: to} do
      endorsement = endorsement_fixture(from, to)
      assert {:ok, %Endorsement{}} = Profiles.delete_endorsement(endorsement)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_endorsement!(endorsement.id) end
    end

    test "change_endorsement/1 returns a endorsement changeset", %{from: from, to: to} do
      endorsement = endorsement_fixture(from, to)
      assert %Ecto.Changeset{} = Profiles.change_endorsement(endorsement)
    end
  end
end
