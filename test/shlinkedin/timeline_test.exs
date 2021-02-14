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
      assert Shlinkedin.Repo.all(Shlinkedin.Timeline.Post) == [post]
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

  describe "templates" do
    alias Shlinkedin.Timeline.Template

    @valid_attrs %{body: "some body", title: "some title"}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    def template_fixture(attrs \\ %{}) do
      {:ok, template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_template()

      template
    end

    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert Timeline.list_templates() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Timeline.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Timeline.create_template(@valid_attrs)
      assert template.body == "some body"
      assert template.title == "some title"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, %Template{} = template} = Timeline.update_template(template, @update_attrs)
      assert template.body == "some updated body"
      assert template.title == "some updated title"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_template(template, @invalid_attrs)
      assert template == Timeline.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Timeline.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Timeline.change_template(template)
    end
  end
end
