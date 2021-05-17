defmodule Shlinkedin.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Chat.Conversation
  alias Shlinkedin.Chat.Message
  alias Shlinkedin.Profiles.Profile

  @doc """
  Gets the count of unread messages for a given profile.
  """
  def get_unread_count(%Profile{} = profile) do
    list_conversations(profile)
    |> Enum.map(fn c -> has_unread?(c, profile) end)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  @doc """
  Tells us whether or not given conversation / profile is unread.

  Returns true if conversation has unread messages for given profile,
  false if not.
  """
  def has_unread?(%Conversation{} = convo, %Profile{} = profile) do
    get_conversation_member!(convo, profile).last_read <
      get_last_message(convo).inserted_at
  end

  def get_last_message(%Conversation{id: id}) do
    Repo.one(
      from m in Message,
        where: m.conversation_id == ^id,
        order_by: [desc: m.inserted_at],
        limit: 1
    )
  end

  @doc """
  Get last n messages for a given conversation.
  """
  def list_messages(%Conversation{id: id}, limit \\ 100) do
    Repo.all(
      from m in Message,
        where: m.conversation_id == ^id,
        order_by: [desc: m.inserted_at],
        limit: ^limit,
        preload: [:profile]
    )
    |> Enum.sort(&(&1.inserted_at < &2.inserted_at))
  end

  def get_conversation_length(%Conversation{id: id}) do
    Repo.aggregate(from(m in Message, where: m.conversation_id == ^id), :count)
  end

  @doc """
  List conversations for a given profile.
  """
  def list_conversations(%Profile{id: id}) do
    Repo.all(
      from c in Conversation,
        where: ^id in c.profile_ids,
        order_by: [desc: c.updated_at]
    )
  end

  @doc """
  Takes a list of profile IDs, and sees if there
  are any conversations that already exist with the given profile IDs.

  Returns a conversation if conversation exists, nil otherwise.

    iex> conversation_exists?([3, 5, 2])
    %Conversation%{id: 3}
  """
  def conversation_exists?(profile_ids) when is_list(profile_ids) do
    Repo.one(from c in Conversation, where: c.profile_ids == ^profile_ids)
  end

  @doc """
  Gets a single conversation.

  Raises `Ecto.NoResultsError` if the Conversation does not exist.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation!(id), do: Repo.get!(Conversation, id)

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a conversation.

  ## Examples

      iex> update_conversation(conversation, %{field: new_value})
      {:ok, %Conversation{}}

      iex> update_conversation(conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation.

  ## Examples

      iex> delete_conversation(conversation)
      {:ok, %Conversation{}}

      iex> delete_conversation(conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation(%Conversation{} = conversation) do
    Repo.delete(conversation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation changes.

  ## Examples

      iex> change_conversation(conversation)
      %Ecto.Changeset{data: %Conversation{}}

  """
  def change_conversation(%Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end

  alias Shlinkedin.Chat.ConversationMember

  @doc """
  Returns the list of chat_conversation_members.

  ## Examples

      iex> list_chat_conversation_members()
      [%ConversationMember{}, ...]

  """
  def list_chat_conversation_members do
    Repo.all(ConversationMember)
  end

  @doc """
  Gets a single conversation_member by profile/conversation.

  Raises `Ecto.NoResultsError` if the Conversation member does not exist.

  ## Examples

      iex> get_conversation_member!(%Conversation{}, %Profile{})
      %ConversationMember{}

      iex> get_conversation_member!(%Conversation{}, %Profile{})
      ** (Ecto.NoResultsError)

  """
  def get_conversation_member!(%Conversation{id: convo_id}, %Profile{id: profile_id}) do
    Repo.one!(
      from c in ConversationMember,
        where: c.conversation_id == ^convo_id and c.profile_id == ^profile_id
    )
  end

  @doc """
  Creates a conversation_member.

  ## Examples

      iex> create_conversation_member(%{field: value})
      {:ok, %ConversationMember{}}

      iex> create_conversation_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation_member(attrs \\ %{}) do
    %ConversationMember{}
    |> ConversationMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a conversation_member.

  ## Examples

      iex> update_conversation_member(conversation_member, %{field: new_value})
      {:ok, %ConversationMember{}}

      iex> update_conversation_member(conversation_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation_member(%ConversationMember{} = conversation_member, attrs) do
    conversation_member
    |> ConversationMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation_member.

  ## Examples

      iex> delete_conversation_member(conversation_member)
      {:ok, %ConversationMember{}}

      iex> delete_conversation_member(conversation_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation_member(%ConversationMember{} = conversation_member) do
    Repo.delete(conversation_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation_member changes.

  ## Examples

      iex> change_conversation_member(conversation_member)
      %Ecto.Changeset{data: %ConversationMember{}}

  """
  def change_conversation_member(%ConversationMember{} = conversation_member, attrs \\ %{}) do
    ConversationMember.changeset(conversation_member, attrs)
  end

  alias Shlinkedin.Chat.Message

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> update_last_message_sent()
  end

  defp update_last_message_sent({:ok, %Message{conversation_id: convo_id} = message}) do
    convo = get_conversation!(convo_id)
    {:ok, _convo} = update_conversation(convo, %{last_message_sent: NaiveDateTime.utc_now()})
    {:ok, message}
  end

  defp update_last_message_sent({:error, err}), do: {:error, err}

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  alias Shlinkedin.Chat.Emoji

  @doc """
  Returns the list of chat_emojis.

  ## Examples

      iex> list_chat_emojis()
      [%Emoji{}, ...]

  """
  def list_chat_emojis do
    Repo.all(Emoji)
  end

  @doc """
  Gets a single emoji.

  Raises `Ecto.NoResultsError` if the Emoji does not exist.

  ## Examples

      iex> get_emoji!(123)
      %Emoji{}

      iex> get_emoji!(456)
      ** (Ecto.NoResultsError)

  """
  def get_emoji!(id), do: Repo.get!(Emoji, id)

  @doc """
  Creates a emoji.

  ## Examples

      iex> create_emoji(%{field: value})
      {:ok, %Emoji{}}

      iex> create_emoji(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_emoji(attrs \\ %{}) do
    %Emoji{}
    |> Emoji.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a emoji.

  ## Examples

      iex> update_emoji(emoji, %{field: new_value})
      {:ok, %Emoji{}}

      iex> update_emoji(emoji, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_emoji(%Emoji{} = emoji, attrs) do
    emoji
    |> Emoji.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a emoji.

  ## Examples

      iex> delete_emoji(emoji)
      {:ok, %Emoji{}}

      iex> delete_emoji(emoji)
      {:error, %Ecto.Changeset{}}

  """
  def delete_emoji(%Emoji{} = emoji) do
    Repo.delete(emoji)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking emoji changes.

  ## Examples

      iex> change_emoji(emoji)
      %Ecto.Changeset{data: %Emoji{}}

  """
  def change_emoji(%Emoji{} = emoji, attrs \\ %{}) do
    Emoji.changeset(emoji, attrs)
  end

  alias Shlinkedin.Chat.MessageReaction

  @doc """
  Returns the list of chat_message_reactions.

  ## Examples

      iex> list_chat_message_reactions()
      [%MessageReaction{}, ...]

  """
  def list_chat_message_reactions do
    Repo.all(MessageReaction)
  end

  @doc """
  Gets a single message_reaction.

  Raises `Ecto.NoResultsError` if the Message reaction does not exist.

  ## Examples

      iex> get_message_reaction!(123)
      %MessageReaction{}

      iex> get_message_reaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message_reaction!(id), do: Repo.get!(MessageReaction, id)

  @doc """
  Creates a message_reaction.

  ## Examples

      iex> create_message_reaction(%{field: value})
      {:ok, %MessageReaction{}}

      iex> create_message_reaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message_reaction(attrs \\ %{}) do
    %MessageReaction{}
    |> MessageReaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message_reaction.

  ## Examples

      iex> update_message_reaction(message_reaction, %{field: new_value})
      {:ok, %MessageReaction{}}

      iex> update_message_reaction(message_reaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message_reaction(%MessageReaction{} = message_reaction, attrs) do
    message_reaction
    |> MessageReaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message_reaction.

  ## Examples

      iex> delete_message_reaction(message_reaction)
      {:ok, %MessageReaction{}}

      iex> delete_message_reaction(message_reaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message_reaction(%MessageReaction{} = message_reaction) do
    Repo.delete(message_reaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message_reaction changes.

  ## Examples

      iex> change_message_reaction(message_reaction)
      %Ecto.Changeset{data: %MessageReaction{}}

  """
  def change_message_reaction(%MessageReaction{} = message_reaction, attrs \\ %{}) do
    MessageReaction.changeset(message_reaction, attrs)
  end

  alias Shlinkedin.Chat.SeenMessage

  @doc """
  Returns the list of chat_seen_messages.

  ## Examples

      iex> list_chat_seen_messages()
      [%SeenMessage{}, ...]

  """
  def list_chat_seen_messages do
    Repo.all(SeenMessage)
  end

  @doc """
  Gets a single seen_message.

  Raises `Ecto.NoResultsError` if the Seen message does not exist.

  ## Examples

      iex> get_seen_message!(123)
      %SeenMessage{}

      iex> get_seen_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_seen_message!(id), do: Repo.get!(SeenMessage, id)

  @doc """
  Creates a seen_message.

  ## Examples

      iex> create_seen_message(%{field: value})
      {:ok, %SeenMessage{}}

      iex> create_seen_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_seen_message(attrs \\ %{}) do
    %SeenMessage{}
    |> SeenMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a seen_message.

  ## Examples

      iex> update_seen_message(seen_message, %{field: new_value})
      {:ok, %SeenMessage{}}

      iex> update_seen_message(seen_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_seen_message(%SeenMessage{} = seen_message, attrs) do
    seen_message
    |> SeenMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a seen_message.

  ## Examples

      iex> delete_seen_message(seen_message)
      {:ok, %SeenMessage{}}

      iex> delete_seen_message(seen_message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seen_message(%SeenMessage{} = seen_message) do
    Repo.delete(seen_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking seen_message changes.

  ## Examples

      iex> change_seen_message(seen_message)
      %Ecto.Changeset{data: %SeenMessage{}}

  """
  def change_seen_message(%SeenMessage{} = seen_message, attrs \\ %{}) do
    SeenMessage.changeset(seen_message, attrs)
  end

  alias Shlinkedin.Chat.MessageTemplate

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%MessageTemplate{}, ...]

  """
  def list_templates() do
    Repo.all(MessageTemplate)
  end

  def list_random_templates(count) do
    Repo.all(
      from t in MessageTemplate,
        where: t.type != "icebreaker",
        order_by: fragment("RANDOM()"),
        limit: ^count
    )
  end

  def get_random_icebreaker() do
    Repo.one(
      from t in MessageTemplate,
        where: t.type == "icebreaker",
        order_by: fragment("RANDOM()"),
        limit: 1
    )
  end

  @doc """
  Gets a single message_template.

  Raises `Ecto.NoResultsError` if the Message template does not exist.

  ## Examples

      iex> get_message_template!(123)
      %MessageTemplate{}

      iex> get_message_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message_template!(id), do: Repo.get!(MessageTemplate, id)

  @doc """
  Creates a message_template.

  ## Examples

      iex> create_message_template(%{field: value})
      {:ok, %MessageTemplate{}}

      iex> create_message_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message_template(attrs \\ %{}) do
    %MessageTemplate{}
    |> MessageTemplate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message_template.

  ## Examples

      iex> update_message_template(message_template, %{field: new_value})
      {:ok, %MessageTemplate{}}

      iex> update_message_template(message_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message_template(%MessageTemplate{} = message_template, attrs) do
    message_template
    |> MessageTemplate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message_template.

  ## Examples

      iex> delete_message_template(message_template)
      {:ok, %MessageTemplate{}}

      iex> delete_message_template(message_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message_template(%MessageTemplate{} = message_template) do
    Repo.delete(message_template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message_template changes.

  ## Examples

      iex> change_message_template(message_template)
      %Ecto.Changeset{data: %MessageTemplate{}}

  """
  def change_message_template(%MessageTemplate{} = message_template, attrs \\ %{}) do
    MessageTemplate.changeset(message_template, attrs)
  end
end
