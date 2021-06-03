defmodule Shlinkedin.ChatTest do
  use Shlinkedin.DataCase

  alias Shlinkedin.Chat

  describe "chat_conversations" do
    alias Shlinkedin.Chat.Conversation

    @valid_attrs %{profile_ids: [1, 2, 3]}
    @update_attrs %{profile_ids: [2, 3]}
    @invalid_attrs %{profile_ids: nil}

    def conversation_fixture(attrs \\ %{}) do
      {:ok, conversation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_conversation()

      conversation
    end

    test "get_conversation!/1 returns the conversation with given id" do
      conversation = conversation_fixture()
      assert Chat.get_conversation!(conversation.id) == conversation
    end

    test "create_conversation/1 with valid data creates a conversation" do
      assert {:ok, %Conversation{} = conversation} = Chat.create_conversation(@valid_attrs)
      assert conversation.profile_ids == [1, 2, 3]

      assert {:ok, %Conversation{} = conversation} =
               Chat.create_conversation(%{profile_ids: [271, 1]})

      assert conversation.profile_ids == [1, 271]

      assert {:ok, %Conversation{} = conversation} =
               Chat.create_conversation(%{"profile_ids" => [382, 238, 10002]})

      assert conversation.profile_ids == [238, 382, 10002]

      assert {:ok, %Conversation{} = conversation} =
               Chat.create_conversation(%{"profile_ids" => [3, 2]})

      assert conversation.profile_ids == [2, 3]
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      conversation = conversation_fixture()

      assert {:ok, %Conversation{} = conversation} =
               Chat.update_conversation(conversation, @update_attrs)

      assert conversation.profile_ids == [2, 3]
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      conversation = conversation_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_conversation(conversation, @invalid_attrs)
      assert conversation == Chat.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      conversation = conversation_fixture()
      assert {:ok, %Conversation{}} = Chat.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      conversation = conversation_fixture()
      assert %Ecto.Changeset{} = Chat.change_conversation(conversation)
    end

    test "create conversation returns error if there's already those users in conversation" do
      assert {:ok, %Conversation{}} = Chat.create_conversation(%{profile_ids: [1, 2, 3]})
      assert {:error, %Ecto.Changeset{}} = Chat.create_conversation(%{profile_ids: [1, 3, 2]})
    end
  end

  describe "templates" do
    alias Shlinkedin.Chat.MessageTemplate

    @valid_attrs %{content: "some content", type: "some type"}
    @update_attrs %{content: "some updated content", type: "some updated type"}
    @invalid_attrs %{content: nil, type: nil}

    def message_template_fixture(attrs \\ %{}) do
      {:ok, message_template} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_message_template()

      message_template
    end

    test "list_templates/0 returns all templates" do
      message_template = message_template_fixture()
      assert Chat.list_templates() == [message_template]
    end

    test "get_message_template!/1 returns the message_template with given id" do
      message_template = message_template_fixture()
      assert Chat.get_message_template!(message_template.id) == message_template
    end

    test "create_message_template/1 with valid data creates a message_template" do
      assert {:ok, %MessageTemplate{} = message_template} =
               Chat.create_message_template(@valid_attrs)

      assert message_template.content == "some content"
      assert message_template.type == "some type"
    end

    test "create_message_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message_template(@invalid_attrs)
    end

    test "update_message_template/2 with valid data updates the message_template" do
      message_template = message_template_fixture()

      assert {:ok, %MessageTemplate{} = message_template} =
               Chat.update_message_template(message_template, @update_attrs)

      assert message_template.content == "some updated content"
      assert message_template.type == "some updated type"
    end

    test "update_message_template/2 with invalid data returns error changeset" do
      message_template = message_template_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Chat.update_message_template(message_template, @invalid_attrs)

      assert message_template == Chat.get_message_template!(message_template.id)
    end

    test "delete_message_template/1 deletes the message_template" do
      message_template = message_template_fixture()
      assert {:ok, %MessageTemplate{}} = Chat.delete_message_template(message_template)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message_template!(message_template.id) end
    end

    test "change_message_template/1 returns a message_template changeset" do
      message_template = message_template_fixture()
      assert %Ecto.Changeset{} = Chat.change_message_template(message_template)
    end
  end
end
