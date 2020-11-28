defmodule Shlinkedin.CommentsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Timeline

  describe "comments" do
    alias Shlinkedin.Timeline.Comment
    alias Shlinkedin.Timeline.Post
    alias Shlinkedin.Accounts.Profile

    @valid_attrs %{body: "some body"}
    @profile %Profile{username: "charlie"}
    @post %Post{body: "hey ther!"}
    @valid_post %{body: "hi!"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{author: nil, body: nil, likes: nil}

    def comment_fixture(attrs \\ %{}) do
      {:ok, comment} =
        Timeline.create_comment(
          @profile,
          @post,
          attrs
          |> Enum.into(@valid_attrs)
        )

      comment
    end

    test "create_comment/1 with valid data creates a comment" do
      assert {:ok, %Post{} = post} = Timeline.create_post(@profile, @valid_post)
      assert {:ok, %Comment{} = comment} = Timeline.create_comment(@profile, post, @valid_attrs)
      assert comment.body == "some body"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Timeline.create_comment(@profile, @post, @invalid_attrs)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Timeline.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_comment!(comment.id) end
    end
  end
end
