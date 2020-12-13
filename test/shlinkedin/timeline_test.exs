defmodule Shlinkedin.TimelineTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Timeline

  describe "posts" do
    alias Shlinkedin.Timeline.Post
    alias Shlinkedin.Profiles.Profile

    @valid_attrs %{
      body: "some body",
      profile: %Profile{username: "charlie"}
    }
    @update_attrs %{
      body: "some updated body",
      profile: %Profile{}
    }
    @invalid_attrs %{body: nil, likes_count: nil, reposts_count: nil, username: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        Timeline.create_post(
          %Profile{},
          attrs
          |> Enum.into(@valid_attrs)
        )

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Timeline.list_posts_no_preload() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} =
               Timeline.create_post(%Profile{username: "charlie"}, @valid_attrs)

      assert post.body == "some body"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(%Profile{}, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Timeline.update_post(%Profile{}, post, @update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(%Profile{}, post, @invalid_attrs)
      assert post == Timeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end
end
