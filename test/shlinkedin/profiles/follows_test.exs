defmodule Shlinkedin.Profiles.FollowsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Profiles

  describe "follows" do
    # get list of following (make sure that it's a list of profile)
    alias Shlinkedin.Profiles.Follow
    import Shlinkedin.ProfilesFixtures

    test "script to get shlinks for profile (to convert to followers)" do
      p1 = profile_fixture()
      p2 = profile_fixture()
      p3 = profile_fixture()

      {:ok, _} = Profiles.send_friend_request(p1, p2)
      {:ok, _} = Profiles.send_friend_request(p1, p3)

      {:ok, _} = Profiles.accept_friend_request(p2, p1)
      {:ok, _} = Profiles.accept_friend_request(p3, p1)

      Profiles.get_connections(p1)
      |> Enum.map(fn connection -> Profiles.create_follow(p1, connection))
      |> IO.inspect(label: "connections")
    end

    test "create_follow/0 works" do
      p1 = profile_fixture()
      p2 = profile_fixture()
      assert {:ok, %Follow{} = _follow} = Profiles.create_follow(p1, p2)
    end

    test "can't follow yourself" do
      p1 = profile_fixture()
      assert {:error, _changeset} = Profiles.create_follow(p1, p1)
    end

    test "can't follow same person twice" do
      p1 = profile_fixture()
      p2 = profile_fixture()
      assert {:ok, %Follow{} = _follow} = Profiles.create_follow(p1, p2)
      assert {:error, _changeset} = Profiles.create_follow(p1, p2)
    end

    test "get_follow!/2 returns follow object" do
      p1 = profile_fixture()
      p2 = profile_fixture()
      assert {:ok, %Follow{} = follow} = Profiles.create_follow(p1, p2)
      assert follow == Profiles.get_follow!(p1.id, p2.id)
    end

    test "list_followers/1 returns all follows" do
      from = profile_fixture()
      another_from = profile_fixture()
      to = profile_fixture()

      {:ok, _follow} = Profiles.create_follow(from, to)
      assert Profiles.list_followers(to) |> Enum.map(& &1.id) == [from.id]
      assert Profiles.list_followers(from) == []

      {:ok, _follow} = Profiles.create_follow(another_from, to)
      assert Profiles.list_followers(to) |> Enum.map(& &1.id) == [from.id, another_from.id]
    end

    test "unfollow/2 deletes the follow" do
      from = profile_fixture()
      to = profile_fixture()
      assert {:ok, %Follow{} = follow} = Profiles.create_follow(from, to)
      assert Profiles.list_followers(to) |> Enum.map(& &1.id) == [from.id]

      assert {:ok, _follow} = Profiles.unfollow(from, to)
      assert Profiles.list_followers(to) |> Enum.map(& &1.id) == []
    end

    # test "list_following/1 returns all following" do
    #   from = profile_fixture()
    #   another_from = profile_fixture()
    #   to = profile_fixture()

    #   {:ok, _follow} = Profiles.create_follow(from, to)
    #   assert Profiles.list_following(to) |> Enum.map(& &1.id) == []
    #   assert Profiles.list_following(from) |> Enum.map(& &1.id) == [to.id]

    #   {:ok, _follow} = Profiles.create_follow(another_from, to)
    #   assert Profiles.list_following(to) |> Enum.map(& &1.id) == []
    #   assert Profiles.list_following(another_from) |> Enum.map(& &1.id) == [to.id]
    # end
  end
end
