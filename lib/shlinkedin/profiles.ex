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

  def grant_award(%Profile{} = profile, %AwardType{} = award_type, attrs \\ %{}) do
    {:ok, _award} =
      %Award{profile_id: profile.id, award_id: award_type.id}
      |> Award.changeset(attrs)
      |> Repo.insert()

    Shlinkedin.Profiles.ProfileNotifier.observer(
      {:ok, award_type.name},
      :new_badge,
      %Profile{id: 3},
      profile
    )
  end

  def revoke_award(%Award{} = award) do
    update_award(award, %{
      active: false
    })
  end

  def list_awards(%Profile{} = profile) do
    Repo.all(
      from a in Award,
        where: a.profile_id == ^profile.id and a.active == true,
        preload: :award_type
    )
  end

  def update_award(%Award{} = award, attrs) do
    award
    |> Award.changeset(attrs)
    |> Repo.update()
  end

  def show_real_name(%Profile{} = from, %Profile{} = to) do
    if from.id == to.id do
      to.real_name
    else
      case check_between_friend_status(from, to) do
        "accepted" -> to.real_name
        _ -> is_profile_private(to)
      end
    end
  end

  defp is_profile_private(%Profile{} = profile) do
    case profile.private_mode do
      true -> "Private 🔒"
      false -> profile.real_name
    end
  end

  @doc """
  Returns the list of endorsements.

  ## Examples

      iex> list_endorsements()
      [%Endorsement{}, ...]

  """
  def list_endorsements(id) do
    Repo.all(from e in Endorsement, where: e.to_profile_id == ^id)
  end

  def list_testimonials(id) do
    Repo.all(from e in Shlinkedin.Profiles.Testimonial, where: e.to_profile_id == ^id)
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
    Repo.all(from e in Shlinkedin.Profiles.Testimonial, where: e.from_profile_id == ^id)
  end

  def list_notifications(id, count) do
    Repo.all(
      from n in Shlinkedin.Profiles.Notification,
        where: n.to_profile_id == ^id,
        limit: ^count,
        preload: [:profile],
        order_by: [desc: n.inserted_at]
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
      from l in Shlinkedin.Timeline.Like,
        group_by: [l.profile_id, l.post_id, l.like_type],
        where: l.inserted_at >= ^start_date,
        select: %{
          post_id: l.post_id,
          profile_id: l.profile_id,
          like_type: l.like_type,
          count: count(l.like_type)
        }

    Repo.all(
      from l in subquery(query),
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
  end

  def list_profiles_by_profile_views(count, start_date) do
    Repo.all(
      from v in ProfileView,
        left_join: profiles in Profile,
        on: v.to_profile_id == profiles.id,
        where: v.from_profile_id != v.to_profile_id and v.inserted_at >= ^start_date,
        group_by: profiles.id,
        select: %{profile: profiles, number: count(v.id)},
        order_by: [desc: count(v.id)],
        limit: ^count
    )
  end

  def list_profiles_by_points(count) do
    Repo.all(
      from p in Profile,
        select: %{profile: p, number: p.points},
        order_by: [desc: p.points],
        limit: ^count
    )
  end

  def get_profile_views_not_yourself(%Profile{} = profile) do
    Repo.aggregate(
      from(v in ProfileView,
        where: v.from_profile_id != ^profile.id
      ),
      :count
    )
  end

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
      from p in Profile,
        where:
          (ilike(p.persona_name, ^sql) or ilike(p.real_name, ^sql) or ilike(p.username, ^sql)) and
            p.persona_name != "test",
        limit: 7,
        order_by: fragment("RANDOM()")
    )
  end

  def list_profiles_preload_users() do
    Repo.all(from p in Profile, preload: :user)
  end

  def list_non_test_profiles() do
    Repo.all(from p in Profile, where: p.persona_name != "test")
  end

  def list_featured_profiles(count) do
    Repo.all(
      from p in Profile, where: p.featured == true, order_by: fragment("RANDOM()"), limit: ^count
    )
  end

  def is_admin?(%Profile{} = profile) do
    Repo.one(from p in Profile, where: p.id == ^profile.id, select: p.admin)
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
      from n in Notification,
        where: n.to_profile_id == ^profile.id and n.read == false,
        select: count("*")
    )
  end

  def get_last_read_notification_time(%Profile{} = profile) do
    Repo.one(
      from n in Notification,
        where: n.to_profile_id == ^profile.id and n.read == false,
        order_by: [desc: n.inserted_at],
        limit: 1,
        select: n.inserted_at
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
           from f in Friend,
             where:
               (f.from_profile_id == ^from.id and f.to_profile_id == ^to.id) or
                 (f.from_profile_id == ^to.id and f.to_profile_id == ^from.id)
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

    #{from.real_name} aka \"#{from.persona_name}\" has invited you to join ShlinkedIn, a social network for satire. To accept their invite,
    <a href="https://www.shlinkedin.com/join?ref=#{from.slug}">click here.</a>

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Email.new_email(
      email,
      "#{from.real_name} invited you to join ShlinkedIn!",
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

  def create_profile_view(%Profile{} = from, %Profile{} = to, attrs \\ %{}) do
    %ProfileView{from_profile_id: from.id, to_profile_id: to.id}
    |> ProfileView.changeset(attrs)
    |> Repo.insert()
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

  def get_pending_requests(%Profile{} = to) do
    Repo.all(
      from f in Friend,
        where: f.to_profile_id == ^to.id and f.status == "pending",
        preload: [:profile]
    )
  end

  def get_connections(%Profile{} = profile) do
    Repo.all(
      from f in Friend,
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
    |> List.flatten()
    |> Enum.reject(fn p -> p.id == profile.id end)
  end

  def get_unique_connection_ids(%Profile{} = profile) do
    Repo.all(
      from f in Friend,
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
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != profile.id end)
  end

  def get_unique_connection_ids(%Profile{} = profile, naive_start_date) do
    Repo.all(
      from f in Friend,
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
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn x -> x != profile.id end)
  end

  def list_friends(%Profile{} = profile) do
    friend_ids = get_unique_connection_ids(profile)
    Repo.all(from p in Profile, where: p.id in ^friend_ids, select: p)
  end

  def list_random_friends(%Profile{} = profile, count) do
    friend_ids = get_unique_connection_ids(profile)

    Repo.all(
      from p in Profile,
        where: p.id in ^friend_ids,
        order_by: fragment("RANDOM()"),
        limit: ^count,
        select: p
    )
  end

  def get_mutual_friends(%Profile{} = from, %Profile{} = to) do
    friends_1 = get_unique_connection_ids(from)
    friends_2 = get_unique_connection_ids(to)

    intersection =
      MapSet.intersection(MapSet.new(friends_1), MapSet.new(friends_2))
      |> MapSet.to_list()

    mutual_ids = intersection -- [from.id, to.id]

    Repo.all(from p in Profile, where: p.id in ^mutual_ids, select: p)
  end

  def check_between_friend_status(%Profile{} = from, %Profile{} = to) do
    if from.id == to.id do
      "me"
    else
      Repo.all(
        from f in Friend,
          select: f.status,
          where:
            (f.from_profile_id == ^from.id and f.to_profile_id == ^to.id) or
              (f.from_profile_id == ^to.id and f.to_profile_id == ^from.id)
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
      from p in Profile,
        order_by: fragment("RANDOM()"),
        limit: ^count,
        where: not ilike(p.persona_name, "%test%") and not like(p.persona_name, "")
    )
  end

  def get_profile_by_user_id(user_id) do
    from(p in Profile, where: p.user_id == ^user_id, select: p) |> Repo.one()
  end

  def get_profile_by_username(username) do
    from(p in Profile, where: p.username == ^username, select: p, preload: :user) |> Repo.one()
  end

  def get_profile_by_profile_id(profile_id) do
    from(p in Profile, where: p.id == ^profile_id, select: p) |> Repo.one()
  end

  def get_profile_by_profile_id_preload_user(profile_id) do
    from(p in Profile, where: p.id == ^profile_id, select: p, preload: [:user]) |> Repo.one()
  end

  def get_profile_by_slug(slug) do
    from(p in Profile, where: p.slug == ^slug, select: p, preload: [:posts]) |> Repo.one()
  end

  def change_profile(%Profile{} = profile, %User{id: user_id}, attrs \\ %{}) do
    Profile.changeset(profile, attrs |> Map.put("user_id", user_id))
  end

  def change_profile_no_user(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

  def create_profile(%User{id: user_id}, attrs \\ %{}, after_save \\ &{:ok, &1}) do
    %Profile{}
    |> Profile.changeset(attrs |> Map.put("user_id", user_id))
    |> Ecto.Changeset.put_change(:slug, attrs["username"])
    |> Repo.insert()
    |> after_save(after_save)
    |> new_profile_notification()
  end

  defp new_profile_notification({:ok, profile}) do
    notify_everyone_except(
      profile,
      %Notification{
        from_profile_id: profile.id,
        type: "new_profile",
        body: "Shlink with them?",
        action: "just joined ShlinkedIn!"
      }
    )

    {:ok, profile}
  end

  defp new_profile_notification({:error, message}), do: {:error, message}

  def update_profile(%Profile{} = profile, %User{id: user_id}, attrs, after_save \\ &{:ok, &1}) do
    profile = %{profile | user_id: user_id}

    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  defp after_save({:ok, profile}, func) do
    {:ok, _profile} = func.(profile)
  end

  defp after_save(error, _func), do: error

  def categories do
    %{
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
end
