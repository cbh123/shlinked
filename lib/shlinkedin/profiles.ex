defmodule Shlinkedin.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Shlinkedin.Repo

  alias Shlinkedin.Awards.AwardType

  alias Shlinkedin.Profiles.{
    Endorsement,
    Award,
    Jab,
    Testimonial,
    ProfileNotifier,
    Profile,
    Notification,
    Friend,
    Invite,
    ProfileView
  }

  alias Shlinkedin.Accounts.User
  alias Shlinkedin.Points

  @doc """
  Checks whether profile is moderator.
  """
  def is_moderator?(nil), do: false
  def is_moderator?(%Profile{admin: true}), do: true
  def is_moderator?(%Profile{id: nil}), do: false

  def is_moderator?(%Profile{} = profile) do
    list_awards(profile)
    |> Enum.find(&(&1.award_type.name == "Moderator"))
    |> case do
      nil -> false
      _ -> true
    end
  end

  def is_platinum?(%Profile{id: nil}), do: false
  def is_platinum?(nil), do: false

  def is_platinum?(%Profile{} = profile) do
    list_awards(profile)
    |> Enum.find(&(&1.award_type.name == "Platinum" or &1.award_type.name == "Shplatinum"))
    |> case do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Num profiles in given time range, used in stats. Uses Timeline.parse_time() function.
  """
  def num_new_profiles(time_range \\ "today") do
    time_in_seconds = Shlinkedin.Helpers.parse_time(time_range)
    time = NaiveDateTime.utc_now() |> NaiveDateTime.add(time_in_seconds, :second)

    query = from p in Profile, where: p.inserted_at >= ^time

    Repo.aggregate(query, :count)
  end

  @doc """
  Grants awards. This can include moderating power.
  """
  def grant_award(
        %Profile{} = granter,
        %Profile{} = recipient,
        %AwardType{} = award_type,
        attrs \\ %{}
      ) do
    %Award{profile_id: recipient.id, award_id: award_type.id}
    |> Award.changeset(attrs)
    |> Award.validate_authorized(granter)
    |> Repo.insert()
    |> Shlinkedin.Profiles.ProfileNotifier.observer(:new_badge, get_god(), recipient)
  end

  def revoke_award(%Award{} = award) do
    update_award(award, %{active: false})
  end

  def list_awards(%Profile{} = profile) do
    Repo.all(
      from(a in Award,
        where: a.profile_id == ^profile.id and a.active == true,
        preload: :award_type
      )
    )
  end

  def update_award(%Award{} = award, attrs) do
    award
    |> Award.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the list of endorsements.

  ## Examples

      iex> list_endorsements()
      [%Endorsement{}, ...]

  """
  def list_endorsements(id) do
    Repo.all(from(e in Endorsement, where: e.to_profile_id == ^id))
  end

  def list_testimonials(id) do
    Repo.all(
      from(e in Shlinkedin.Profiles.Testimonial,
        where: e.to_profile_id == ^id,
        order_by: [desc: e.inserted_at]
      )
    )
  end

  def get_number_testimonials(id) do
    Repo.aggregate(
      from(t in Shlinkedin.Profiles.Testimonial, where: t.to_profile_id == ^id),
      :count,
      :id
    )
  end

  def get_number_given_testimonials(id) do
    Repo.aggregate(
      from(t in Shlinkedin.Profiles.Testimonial, where: t.from_profile_id == ^id),
      :count,
      :id
    )
  end

  def list_given_testimonials(id) do
    Repo.all(
      from(e in Shlinkedin.Profiles.Testimonial,
        where: e.from_profile_id == ^id,
        order_by: [desc: e.inserted_at]
      )
    )
  end

  def list_notifications(id, count) do
    Repo.all(
      from(n in Shlinkedin.Profiles.Notification,
        where: n.to_profile_id == ^id,
        limit: ^count,
        preload: [:profile],
        order_by: [desc: n.inserted_at]
      )
    )
  end

  def list_profiles() do
    Repo.all(from(p in Profile))
  end

  # Leaderboard stuff
  def list_profiles_by_shlink_count(count, start_date) do
    list_profiles()
    |> Enum.map(fn p ->
      %{number: length(get_unique_connection_ids(p, start_date)), profile: p}
    end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.slice(0..count)
  end

  def list_profiles_by_ad_clicks(count, start_date) do
    list_profiles()
    |> Enum.map(fn p ->
      %{number: length(Shlinkedin.Ads.list_unique_ad_clicks(p, start_date)), profile: p}
    end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.slice(0..count)
  end

  def list_profiles_by_article_votes(count, start_date) do
    list_profiles()
    |> Enum.map(fn p ->
      %{number: length(Shlinkedin.News.list_unique_article_votes(p, start_date)), profile: p}
    end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.slice(0..count)
  end

  def list_profiles_by_unique_post_reactions(count, start_date) do
    query =
      from(l in Shlinkedin.Timeline.Like,
        group_by: [l.profile_id, l.post_id, l.like_type],
        where: l.inserted_at >= ^start_date,
        select: %{
          post_id: l.post_id,
          profile_id: l.profile_id,
          like_type: l.like_type,
          count: count(l.like_type)
        }
      )

    Repo.all(
      from(l in subquery(query),
        left_join: posts in Shlinkedin.Timeline.Post,
        on: posts.id == l.post_id,
        left_join: profiles in Profile,
        on: posts.profile_id == profiles.id,
        group_by: profiles.id,
        where: l.profile_id != posts.profile_id,
        select: %{profile: profiles, number: count(l.like_type)},
        order_by: [desc: count(l.like_type)],
        limit: ^count
      )
    )
  end

  def list_profiles_by_profile_views(count, start_date) do
    Repo.all(
      from(v in ProfileView,
        left_join: profiles in Profile,
        on: v.to_profile_id == profiles.id,
        where: v.from_profile_id != v.to_profile_id and v.inserted_at >= ^start_date,
        group_by: profiles.id,
        select: %{profile: profiles, number: count(v.id)},
        order_by: [desc: count(v.id)],
        limit: ^count
      )
    )
  end

  def list_profiles_by_work_streak(count) do
    Repo.all(
      from(p in Profile,
        select: %{profile: p, number: p.work_streak},
        order_by: [desc: p.work_streak],
        limit: ^count
      )
    )
  end

  def list_profiles_by_points(count) do
    Repo.all(
      from(p in Profile,
        select: %{profile: p, number: p.points},
        order_by: [desc: p.points],
        limit: ^count
      )
    )
  end

  def get_profile_views_not_yourself(%Profile{} = profile) do
    Repo.aggregate(
      from(v in ProfileView,
        where: v.from_profile_id != ^profile.id and v.to_profile_id == ^profile.id
      ),
      :count
    )
  end

  @doc """
  Gets God profile. We need this because sometimes Dave Business
  / God sends people notifications and points.

  If no username is "god", returns new profile fixture. So in prod,
  it always returns god. In dev it returns new god fixture.
  """
  def get_god do
    get_profile_by_username("god")
    |> get_god_profile()
  end

  defp get_god_profile(nil) do
    {:ok, user} =
      Shlinkedin.Accounts.register_user(%{email: "god@shlinkedin.com", password: "bloop"})

    {:ok, profile} =
      create_profile(user, %{
        "persona_name" => "god",
        "slug" => "god",
        "title" => "god",
        "username" => "god"
      })

    profile
  end

  defp get_god_profile(god), do: god

  @doc """
  Given a profile, number of profiles to include,
  and leaderboard category, return the profiles's ranking
  in that category. Subtracts 23 hours to put the ranking as
  of this week's sunday 6pm.
  """
  def get_ranking(%Profile{} = profile, count, category) do
    rankings =
      match_cat(
        category,
        count,
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(-(23 * 60 * 60))
        |> Timex.beginning_of_week(:sun)
      )

    case Enum.find_index(rankings, fn res -> res.profile.id == profile.id end) do
      nil -> nil
      number -> number + 1
    end
  end

  def get_all_rankings(%Profile{} = profile, count) do
    category_names = categories() |> Map.keys()

    Enum.map(category_names, fn c ->
      %{
        category: Atom.to_string(c),
        ranking: get_ranking(profile, count, Atom.to_string(c)),
        emoji: categories()[c].emoji
      }
    end)
  end

  def match_cat(category, count, start_date) do
    case category do
      "Shlinks" -> list_profiles_by_shlink_count(count, start_date)
      "Post Reactions" -> list_profiles_by_unique_post_reactions(count, start_date)
      "Claps" -> list_profiles_by_article_votes(count, start_date)
      "Ads" -> list_profiles_by_ad_clicks(count, start_date)
      "Hottest" -> list_profiles_by_profile_views(count, start_date)
      "Wealth" -> list_profiles_by_points(count)
      "Work" -> list_profiles_by_work_streak(count)
    end
  end

  def match_emoji(category) do
    case category do
      "Shlinks" -> "hi"
      _ -> "hi"
    end
  end

  def search_profiles(persona_or_real) do
    sql = "%#{persona_or_real}%"

    Repo.all(
      from(p in Profile,
        where:
          (ilike(p.persona_name, ^sql) or ilike(p.username, ^sql)) and
            p.persona_name != "test",
        limit: 7,
        order_by: fragment("RANDOM()")
      )
    )
  end

  def list_profiles_preload_users() do
    Repo.all(from(p in Profile, preload: :user))
  end

  def list_non_test_profiles(limit \\ 50) do
    Repo.all(from(p in Profile, where: p.persona_name != "test", limit: ^limit))
  end

  def list_featured_profiles(count) do
    Repo.all(
      from(p in Profile, where: p.featured == true, order_by: fragment("RANDOM()"), limit: ^count)
    )
  end

  def is_admin?(nil), do: false

  def is_admin?(%Profile{} = profile) do
    Repo.one(from(p in Profile, where: p.id == ^profile.id, select: p.admin))
  end

  def change_notification_to_read(id) do
    %Notification{id: id}
    |> Ecto.Changeset.change(read: true)
    |> Repo.update()
  end

  def update_last_read_notification(profile_id) do
    %Profile{id: profile_id}
    |> Ecto.Changeset.change(
      last_checked_notifications: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    )
    |> Repo.update()
  end

  def mark_all_notifications_read(%Profile{} = profile) do
    from(n in Notification, where: n.to_profile_id == ^profile.id)
    |> Repo.update_all(set: [read: true])
  end

  def get_unread_notification_count(%Profile{} = profile) do
    Repo.one(
      from(n in Notification,
        where: n.to_profile_id == ^profile.id and n.read == false,
        select: count("*")
      )
    )
  end

  def get_last_read_notification_time(%Profile{id: nil}), do: nil

  def get_last_read_notification_time(%Profile{} = profile) do
    Repo.one(
      from(n in Notification,
        where: n.to_profile_id == ^profile.id and n.read == false,
        order_by: [desc: n.inserted_at],
        limit: 1,
        select: n.inserted_at
      )
    )
  end

  @doc """
  Gets a single endorsement.

  Raises `Ecto.NoResultsError` if the Endorsement does not exist.

  ## Examples

      iex> get_endorsement!(123)
      %Endorsement{}

      iex> get_endorsement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_endorsement!(id), do: Repo.get!(Endorsement, id)

  def get_award!(id), do: Repo.get!(Award, id)

  def get_testimonial!(id), do: Repo.get!(Testimonial, id)

  def get_notification!(id), do: Repo.get!(Notification, id)

  def get_friend_request!(%Profile{} = from, %Profile{} = to) do
    case Repo.one(
           from(f in Friend,
             where:
               (f.from_profile_id == ^from.id and f.to_profile_id == ^to.id) or
                 (f.from_profile_id == ^to.id and f.to_profile_id == ^from.id)
           )
         ) do
      nil -> %Friend{from_profile_id: from.id, to_profile_id: to.id}
      friend -> friend
    end
  end

  @doc """
  Creates a endorsement.

  ## Examples

      iex> create_endorsement(%{field: value})
      {:ok, %Endorsement{}}

      iex> create_endorsement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(
        %Notification{} = notification,
        attrs \\ %{}
      ) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  def create_invite(%Invite{} = invite, attrs \\ %{}) do
    invite
    |> Invite.changeset(attrs)
    |> Repo.insert()
    |> send_email_invite()
  end

  def send_email_invite({:error, msg}), do: {:error, msg}

  def send_email_invite({:ok, %Invite{profile_id: profile_id, email: email} = invite}) do
    from = get_profile_by_profile_id(profile_id)

    body = """

    Hi there,

    <br/>
    <br/>

    #{from.persona_name} has invited you to join ShlinkedIn, a social network for satire. To accept their invite,
    <a href="https://www.shlinkedin.com/join?ref=#{from.slug}">click here.</a>

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Email.new_email(
      email,
      "#{from.persona_name} invited you to join ShlinkedIn!",
      body
    )
    |> Shlinkedin.Mailer.deliver_later()

    {:ok, invite}
  end

  def notify_everyone(%Notification{} = notification, attrs \\ %{}) do
    for p <- list_profiles() do
      create_notification(notification, attrs |> Map.put("to_profile_id", p.id))
    end
  end

  def notify_everyone_except(%Profile{} = except, %Notification{} = notification, attrs \\ %{}) do
    for p <- list_profiles() do
      if except.id != p.id do
        create_notification(notification, attrs |> Map.put("to_profile_id", p.id))
      end
    end
  end

  def admin_create_notification(
        %Notification{} = notification,
        attrs \\ %{},
        notify_all
      ) do
    case notify_all[:notify_all] do
      "false" ->
        create_notification(notification, attrs)

      "true" ->
        for p <- list_profiles() do
          create_notification(notification, attrs |> Map.put("to_profile_id", p.id))
        end

        {:ok, "Sent to everyone"}
    end
  end

  def admin_email_all(subject, body, notify_all, profile \\ %Profile{}) do
    case notify_all do
      "false" ->
        Shlinkedin.Email.new_email(
          profile.user.email,
          subject,
          body
        )
        |> Shlinkedin.Mailer.deliver_later()

      "true" ->
        for p <- list_profiles_preload_users() do
          if p.unsubscribed == false do
            Shlinkedin.Email.new_email(
              p.user.email,
              subject,
              body
            )
            |> Shlinkedin.Mailer.deliver_later()
          end
        end
    end
  end

  def create_endorsement(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %Endorsement{from_profile_id: from.id, to_profile_id: to.id}
    |> Endorsement.changeset(attrs)
    |> Repo.insert()
    |> ProfileNotifier.observer(:endorsement, from, to)
  end

  def create_testimonial(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %Testimonial{from_profile_id: from.id, to_profile_id: to.id}
    |> Testimonial.changeset(attrs)
    |> Repo.insert()
    |> ProfileNotifier.observer(:testimonial, from, to)
  end

  @doc """
  Creates a profile view under two criteria: it's not from yourself, and it's more than
  1hr ago.
  """
  def create_profile_view(from, to, attrs \\ %{})

  def create_profile_view(%Profile{id: nil}, _profile, _attrs), do: {:ok, nil}

  def create_profile_view(%Profile{} = from, %Profile{} = to, attrs) do
    if from.id != to.id and count_profile_views_in_timeframe(from, to, -3600) == 0 do
      {:ok, _txn} = Points.generate_wealth(to, :profile_view)
    end

    %ProfileView{from_profile_id: from.id, to_profile_id: to.id}
    |> ProfileView.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Counts profile views in timeframe, default to last 5min
  """
  def count_profile_views_in_timeframe(
        %Profile{} = from,
        %Profile{} = to,
        sec_ago \\ -600
      ) do
    time = NaiveDateTime.utc_now() |> NaiveDateTime.add(sec_ago, :second)

    Repo.aggregate(
      from(v in ProfileView,
        where:
          v.from_profile_id == ^from.id and v.to_profile_id == ^to.id and
            v.inserted_at >= ^time
      ),
      :count
    )
  end

  def send_friend_request(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    friend = get_friend_request!(from, to)

    friend
    |> Friend.changeset(%{status: "pending"})
    |> Friend.changeset(attrs)
    |> Repo.insert_or_update()
    |> ProfileNotifier.observer(:sent_friend_request, from, to)
  end

  def send_jab(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %Jab{from_profile_id: from.id, to_profile_id: to.id}
    |> Jab.changeset(attrs)
    |> Repo.insert()
    |> ProfileNotifier.observer(:jab, from, to)
  end

  def count_jabs(%Profile{} = profile) do
    Repo.aggregate(from(j in Jab, where: j.from_profile_id == ^profile.id), :count)
  end

  def count_jabs_in_timeframe(%Profile{} = profile, sec_ago \\ -600) do
    time = NaiveDateTime.utc_now() |> NaiveDateTime.add(sec_ago, :second)

    Repo.aggregate(
      from(j in Jab, where: j.from_profile_id == ^profile.id and j.inserted_at >= ^time),
      :count
    )
  end

  def count_written_endorsements(%Profile{} = profile) do
    Repo.aggregate(from(e in Endorsement, where: e.from_profile_id == ^profile.id), :count)
  end

  def count_invites(%Profile{} = profile) do
    Repo.aggregate(from(i in Invite, where: i.profile_id == ^profile.id), :count)
  end

  def cancel_friend_request(%Profile{} = from, %Profile{} = to) do
    request = get_friend_request!(from, to)

    request
    |> Friend.changeset(%{status: nil})
    |> Repo.update()
  end

  def accept_friend_request(%Profile{} = from, %Profile{} = to) do
    request = get_friend_request!(from, to)

    request
    |> Friend.changeset(%{status: "accepted"})
    |> Repo.update()
    |> ProfileNotifier.observer(:accepted_friend_request, from, to)
  end

  def get_pending_requests(%Profile{id: nil}) do
    []
  end

  def get_pending_requests(%Profile{} = to) do
    Repo.all(
      from(f in Friend,
        where: f.to_profile_id == ^to.id and f.status == "pending",
        preload: [:profile]
      )
    )
  end

  def get_connections(%Profile{} = profile) do
    Repo.all(
      from(f in Friend,
        where:
          (f.to_profile_id == ^profile.id or f.from_profile_id == ^profile.id) and
            f.status == "accepted",
        join: p in Profile,
        as: :profile,
        on: f.from_profile_id == p.id,
        join: p2 in Profile,
        as: :to_profile,
        on: f.to_profile_id == p2.id,
        select: [p, p2]
      )
    )
    |> List.flatten()
    |> Enum.reject(fn p -> p.id == profile.id end)
  end

  def get_unique_connection_ids(%Profile{} = profile) do
    Repo.all(
      from(f in Friend,
        where:
          (f.to_profile_id == ^profile.id or f.from_profile_id == ^profile.id) and
            f.status == "accepted",
        join: p in Profile,
        as: :profile,
        on: f.from_profile_id == p.id,
        join: p2 in Profile,
        as: :to_profile,
        on: f.to_profile_id == p2.id,
        select: [p.id, p2.id]
      )
    )
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != profile.id end)
  end

  def get_unique_connection_ids(%Profile{} = profile, naive_start_date) do
    Repo.all(
      from(f in Friend,
        where:
          (f.to_profile_id == ^profile.id or f.from_profile_id == ^profile.id) and
            f.status == "accepted" and f.inserted_at >= ^naive_start_date,
        join: p in Profile,
        as: :profile,
        on: f.from_profile_id == p.id,
        join: p2 in Profile,
        as: :to_profile,
        on: f.to_profile_id == p2.id,
        select: [p.id, p2.id]
      )
    )
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != profile.id end)
  end

  def list_friends(%Profile{} = profile) do
    friend_ids = get_unique_connection_ids(profile)
    Repo.all(from(p in Profile, where: p.id in ^friend_ids, select: p))
  end

  def list_random_friends(%Profile{} = profile, count) do
    friend_ids = get_unique_connection_ids(profile)

    Repo.all(
      from(p in Profile,
        where: p.id in ^friend_ids,
        order_by: fragment("RANDOM()"),
        limit: ^count,
        select: p
      )
    )
  end

  def get_mutual_friends(%Profile{} = from, %Profile{} = to) do
    friends_1 = get_unique_connection_ids(from)
    friends_2 = get_unique_connection_ids(to)

    intersection =
      MapSet.intersection(MapSet.new(friends_1), MapSet.new(friends_2))
      |> MapSet.to_list()

    mutual_ids = intersection -- [from.id, to.id]

    Repo.all(from(p in Profile, where: p.id in ^mutual_ids, select: p))
  end

  def check_between_friend_status(nil, %Profile{}), do: nil
  def check_between_friend_status(%Profile{id: nil}, %Profile{}), do: nil

  def check_between_friend_status(%Profile{} = from, %Profile{} = to) do
    if from.id == to.id do
      "me"
    else
      Repo.all(
        from(f in Friend,
          select: f.status,
          where:
            (f.from_profile_id == ^from.id and f.to_profile_id == ^to.id) or
              (f.from_profile_id == ^to.id and f.to_profile_id == ^from.id)
        )
      )
      |> Enum.uniq()
      |> Enum.at(0)
    end
  end

  @doc """
  Updates a endorsement.

  ## Examples

      iex> update_endorsement(endorsement, %{field: new_value})
      {:ok, %Endorsement{}}

      iex> update_endorsement(endorsement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_endorsement(%Endorsement{} = endorsement, attrs) do
    endorsement
    |> Endorsement.changeset(attrs)
    |> Repo.update()
  end

  def update_testimonial(%Testimonial{} = testimonial, attrs) do
    testimonial
    |> Testimonial.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a endorsement.

  ## Examples

      iex> delete_endorsement(endorsement)
      {:ok, %Endorsement{}}

      iex> delete_endorsement(endorsement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_endorsement(%Endorsement{} = endorsement) do
    Repo.delete(endorsement)
  end

  def delete_award(%Award{} = award) do
    Repo.delete(award)
  end

  def delete_testimonial(%Testimonial{} = testimonial) do
    Repo.delete(testimonial)
  end

  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking endorsement changes.

  ## Examples

      iex> change_endorsement(endorsement)
      %Ecto.Changeset{data: %Endorsement{}}

  """
  def change_endorsement(%Endorsement{} = endorsement, attrs \\ %{}) do
    Endorsement.changeset(endorsement, attrs)
  end

  def change_testimonial(%Testimonial{} = testimonial, attrs \\ %{}) do
    Testimonial.changeset(testimonial, attrs)
  end

  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  def change_invite(%Invite{} = invite, attrs \\ %{}) do
    Invite.changeset(invite, attrs)
  end

  def list_random_profiles(count) do
    Repo.all(
      from(p in Profile,
        order_by: fragment("RANDOM()"),
        limit: ^count,
        where: not ilike(p.persona_name, "%test%") and not like(p.persona_name, "")
      )
    )
  end

  def get_profile_by_user_id(user_id) do
    from(p in Profile, where: p.user_id == ^user_id, select: p) |> Repo.one()
  end

  def get_profile_by_username(username) do
    from(p in Profile, where: p.username == ^username, select: p, preload: :user) |> Repo.one()
  end

  @doc """
  Gets profile by id. Expects one result.

  Returns profile | nil
  """
  def get_profile_by_profile_id(profile_id) do
    from(p in Profile, where: p.id == ^profile_id) |> Repo.one()
  end

  def get_profile_by_profile_id_preload_user(profile_id) do
    from(p in Profile, where: p.id == ^profile_id, select: p, preload: [:user]) |> Repo.one()
  end

  def get_profile_by_user_id_preload_conversations(profile_id) do
    from(p in Profile, where: p.id == ^profile_id, select: p, preload: [:conversations])
    |> Repo.one()
  end

  def get_profile_by_slug(slug) do
    Repo.get_by(Profile, slug: slug)
  end

  def get_profile_by_slug!(slug) do
    Repo.get_by!(Profile, slug: slug)
  end

  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

  @doc """
  Creates a profile without a user.
  """
  def create_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a profile given a username.
  """
  def create_profile(
        %User{id: user_id},
        attrs,
        after_save \\ &{:ok, &1}
      ) do
    %Profile{
      user_id: user_id,
      slug: attrs["username"]
    }
    |> Profile.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  def update_profile(profile, user, attrs, after_save \\ &{:ok, &1})

  def update_profile(
        %Profile{} = profile,
        %User{id: user_id},
        %{"username" => username} = attrs,
        after_save
      ) do
    attrs = Map.put(attrs, "slug", username)

    %{profile | user_id: user_id}
    |> Profile.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  def update_profile(%Profile{} = profile, %User{id: user_id}, attrs, after_save) do
    %{profile | user_id: user_id}
    |> Profile.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  def nullify_profile(%Profile{} = profile) do
    profile
    |> Profile.changeset(%{
      persona_name: "deleted",
      photo_url: nil,
      cover_photo_url: nil,
      life_score: nil,
      point: 0,
      verified: false,
      spotify_song_url: nil,
      summary: nil
    })
    |> Repo.update()
  end

  defp after_save({:ok, profile}, func) do
    {:ok, _profile} = func.(profile)
  end

  defp after_save(error, _func), do: error

  def categories do
    %{
      Work: %{
        title: "Streak",
        desc: "Best Employee",
        emoji: "💼"
      },
      Shlinks: %{
        title: "count",
        desc: "Total number of shlinked connections.",
        emoji: "🤝"
      },
      Wealth: %{
        title: "points",
        desc: "Total number of ShlinkPoints",
        emoji: "💰"
      },
      "Post Reactions": %{
        title: "reactions",
        desc:
          "The most prestigous ranking - the number of unique post reactions. The number of reactions don't matter (100 YoYs counts just as much as 1) and, reactions on your own post aren't included.",
        emoji: "🪧"
      },
      Claps: %{
        title: "claps",
        desc: "Unique headline claps.",
        emoji: "👏"
      },
      Ads: %{
        title: "unique clicks",
        desc: "Unique clicks on your ad. You can only get max 1 click from each person per ad.",
        emoji: "👁️"
      },
      Hottest: %{
        title: "profile views",
        desc: "Unique profile views, from everyone but yourself.",
        emoji: "🔥"
      }
    }
  end

  alias Shlinkedin.Profiles.Work

  @doc """
  Returns the list of work.

  ## Examples

      iex> list_work()
      [%Work{}, ...]

  """
  def list_work(%Profile{id: profile_id}) do
    from(w in Work, where: w.profile_id == ^profile_id)
    |> Repo.all()
  end

  def get_work_streak(%Profile{id: profile_id}) do
    from(w in Work, where: w.profile_id == ^profile_id)
    |> Repo.all()
    |> Enum.map(fn w -> w.inserted_at end)
    |> Enum.map(fn d -> NaiveDateTime.to_date(d) end)
    |> Enum.sort({:desc, Date})
    |> get_streak_as_of_today()
  end

  def get_work_streak(nil) do
    0
  end

  def has_worked_today?(%Profile{id: profile_id}) do
    today = NaiveDateTime.utc_now() |> NaiveDateTime.to_date()

    from(w in Work,
      where: w.profile_id == ^profile_id and fragment("?::date", w.inserted_at) == ^today
    )
    |> Repo.one() != nil
  end

  def has_worked_today?(nil) do
    false
  end

  @doc """
  Returns work streak as of today - so even if there was a long date streak
  in the past, it only matters what the streak is starting with today and working backwards.

  # When today is 2022-05-07:
  iex> get_streak_as_of_today([~D[2022-05-07], ~D[2022-05-06], ~D[2022-05-04]])
  2
  # When today is 2022-05-08:
  iex> get_streak_as_of_today([~D[2022-05-07], ~D[2022-05-06], ~D[2022-05-04]])
  2
  # When today is 2022-05-09:
  iex> get_streak_as_of_today([~D[2022-05-07], ~D[2022-05-06], ~D[2022-05-04]])
  0
  """
  def get_streak_as_of_today([]), do: 0

  def get_streak_as_of_today([last | _] = dates) do
    today = NaiveDateTime.utc_now() |> NaiveDateTime.to_date()

    if today == last or Date.diff(today, last) == 1 do
      get_streak(dates)
    else
      0
    end
  end

  def get_streak(dates), do: _get_streak(dates, 1)

  defp _get_streak([curr | [prev | _] = tail], acc) do
    if Date.diff(curr, prev) == 1 do
      _get_streak(tail, acc + 1)
    else
      _get_streak([], acc)
    end
  end

  defp _get_streak(_, acc), do: acc

  @doc """
  Gets a single work.

  Raises `Ecto.NoResultsError` if the Work does not exist.

  ## Examples

      iex> get_work!(123)
      %Work{}

      iex> get_work!(456)
      ** (Ecto.NoResultsError)

  """
  def get_work!(id), do: Repo.get!(Work, id)

  @doc """
  Creates a work.

  ## Examples

      iex> create_work(%{field: value})
      {:ok, %Work{}}

      iex> create_work(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_work(%Profile{} = profile, attrs \\ %{}) do
    %Work{}
    |> Work.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:profile, profile)
    |> Repo.insert()
  end

  @doc """
  Updates a work.

  ## Examples

      iex> update_work(work, %{field: new_value})
      {:ok, %Work{}}

      iex> update_work(work, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_work(%Work{} = work, attrs) do
    work
    |> Work.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a work.

  ## Examples

      iex> delete_work(work)
      {:ok, %Work{}}

      iex> delete_work(work)
      {:error, %Ecto.Changeset{}}

  """
  def delete_work(%Work{} = work) do
    Repo.delete(work)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work changes.

  ## Examples

      iex> change_work(work)
      %Ecto.Changeset{data: %Work{}}

  """
  def change_work(%Work{} = work, attrs \\ %{}) do
    Work.changeset(work, attrs)
  end

  # Follows
  alias Shlinkedin.Profiles.Follow

  @doc """
  Returns the list of profiles that follow given profile.

  ## Examples

      iex> list_follows(Profiles)
      [%Follow{}, ...]

  """
  def list_followers(%Profile{id: id}) do
    from(f in Follow,
      preload: :profile,
      where: f.to_profile_id == ^id
    )
    |> Repo.all()
    |> Enum.map(fn w -> w.profile end)
  end

  @doc """
  Returns the list of profiles following given profile.

  TODO.
  """
  def list_following(%Profile{id: id}) do
    from(f in Follow,
      where: f.from_profile_id == ^id
    )
    |> Repo.all()
    |> Enum.map(fn w -> w.profile end)

    raise "Not Implemented"
  end

  @doc """
  Returns following status. True if already following, else nil.
  """
  def is_following?(%Profile{id: from_profile_id}, %Profile{id: to_profile_id}) do
    Repo.get_by(Follow, from_profile_id: from_profile_id, to_profile_id: to_profile_id)
  end

  @doc """
  Creates a follow.

  ## Examples

      iex> create_follow(%{from_profile_id: 1, to_profile_id: 3})
      {:ok, %Follow{}}

  """
  def create_follow(%Profile{id: from_profile_id} = from, %Profile{id: to_profile_id} = to)
      when from_profile_id != to_profile_id do
    %Follow{from_profile_id: from_profile_id, to_profile_id: to_profile_id}
    |> Follow.changeset(%{})
    |> Repo.insert()
    |> ProfileNotifier.observer(:new_follower, from, to)
  end

  def create_follow(_, _), do: {:error, "You cannot follow yourself"}

  def get_follow!(from_profile_id, to_profile_id) do
    Repo.get_by!(Follow, from_profile_id: from_profile_id, to_profile_id: to_profile_id)
  end

  def unfollow(%Profile{id: from_profile_id}, %Profile{id: to_profile_id}) do
    {:ok, _follow} =
      get_follow!(from_profile_id, to_profile_id)
      |> delete_follow()
  end

  @doc """
  Deletes a follow.

  ## Examples

      iex> delete_follow(follow)
      {:ok, %Follow{}}

      iex> delete_follow(follow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%Follow{} = follow) do
    Repo.delete(follow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follow changes.

  ## Examples

      iex> change_follow(follow)
      %Ecto.Changeset{data: %Follow{}}

  """
  def change_follow(%Follow{} = follow, attrs \\ %{}) do
    Follow.changeset(follow, attrs)
  end
end
