defmodule Shlinkedin.CommentsTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Timeline

  describe "comments" do
    alias Shlinkedin.Timeline.Comment

    @valid_attrs %{author: "some author", body: "some body"}
    @update_attrs %{author: "some updated author", body: "some updated body", likes: 43}
    @invalid_attrs %{author: nil, body: nil, likes: nil}

    def comment_fixture(attrs \\ %{}) do
      {:ok, comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_comment()

      comment
    end

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Timeline.list_comments() == [comment]
    end

    test "create_comment/1 with valid data creates a comment" do
      assert {:ok, %Comment{} = comment} = Timeline.create_comment(@valid_attrs)
      assert comment.author == "some author"
      assert comment.body == "some body"
      assert comment.likes == 42
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_comment(@invalid_attrs)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Timeline.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_comment!(comment.id) end
    end
  end
end
