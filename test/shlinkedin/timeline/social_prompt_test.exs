defmodule Shlinkedin.Timeline.SocialPromptTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Timeline

  describe "social_prompts" do
    alias Shlinkedin.Timeline.SocialPrompt

    @valid_attrs %{active: true, text: "some text"}
    @update_attrs %{active: false, text: "some updated text"}
    @invalid_attrs %{active: nil, text: nil}

    def social_prompt_fixture(attrs \\ %{}) do
      {:ok, social_prompt} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_social_prompt()

      social_prompt
    end

    test "list_social_prompts/0 returns all social_prompts" do
      social_prompt = social_prompt_fixture()
      assert Timeline.list_social_prompts() == [social_prompt]
    end

    test "get_social_prompt!/1 returns the social_prompt with given id" do
      social_prompt = social_prompt_fixture()
      assert Timeline.get_social_prompt!(social_prompt.id) == social_prompt
    end

    test "create_social_prompt/1 with valid data creates a social_prompt" do
      assert {:ok, %SocialPrompt{} = social_prompt} = Timeline.create_social_prompt(@valid_attrs)

      assert social_prompt.active == true
      assert social_prompt.text == "some text"
    end

    test "create_social_prompt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_social_prompt(@invalid_attrs)
    end

    test "update_social_prompt/2 with valid data updates the social_prompt" do
      social_prompt = social_prompt_fixture()

      assert {:ok, %SocialPrompt{} = social_prompt} =
               Timeline.update_social_prompt(social_prompt, @update_attrs)

      assert social_prompt.active == false
      assert social_prompt.text == "some updated text"
    end

    test "update_social_prompt/2 with invalid data returns error changeset" do
      social_prompt = social_prompt_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Timeline.update_social_prompt(social_prompt, @invalid_attrs)

      assert social_prompt == Timeline.get_social_prompt!(social_prompt.id)
    end

    test "delete_social_prompt/1 deletes the social_prompt" do
      social_prompt = social_prompt_fixture()
      assert {:ok, %SocialPrompt{}} = Timeline.delete_social_prompt(social_prompt)

      assert_raise Ecto.NoResultsError, fn ->
        Timeline.get_social_prompt!(social_prompt.id)
      end
    end

    test "change_social_prompt/1 returns a social_prompt changeset" do
      social_prompt = social_prompt_fixture()
      assert %Ecto.Changeset{} = Timeline.change_social_prompt(social_prompt)
    end
  end
end
