defmodule Shlinkedin.Levels do
  alias ShlinkedinWeb.Router.Helpers, as: Routes
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles

  def profile_level(socket, %Profile{} = profile) do
    get_current_level(profile, socket) |> level_names()
  end

  def level_names(level) do
    case level do
      0 -> "☕ Unpaid Intern"
      1 -> "💵 Paid Intern"
      2 -> "💼 Middle Manager"
      3 -> "💰 CEO"
      4 -> "🏦 Business Titan"
      5 -> "🗣️ Thought Leader"
      _ -> "☕ Unpaid Intern"
    end
  end

  def checklists(profile, socket) do
    %{
      0 => [
        %{
          done: true,
          route: Routes.home_index_path(socket, :index),
          name: "JoinShlinkedIn"
        },
        %{
          name: "Add a profile photo",
          route: Routes.profile_edit_path(socket, :edit),
          done:
            profile.photo_url !=
              "https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/George_Washington%2C_1776.jpg/1200px-George_Washington%2C_1776.jpg"
        },
        %{
          name: "Add a headline",
          route: Routes.profile_edit_path(socket, :edit),
          done: !is_nil(profile.persona_title)
        },
        %{
          name: "Write your first post",
          route: Routes.home_index_path(socket, :new),
          done: Shlinkedin.Timeline.num_posts(profile) > 0
        }
      ],
      1 => [
        %{
          done: length(Profiles.list_friends(profile)) > 0,
          route: Routes.users_index_path(socket, :index),
          name: "Make 1 connection"
        },
        %{
          done: Shlinkedin.Points.get_balance(profile) |> Money.compare(Money.new(1000)) == 1,
          route: Routes.points_index_path(socket, :index),
          name:
            "Earn 10 ShlinkPoints (current balance: #{Shlinkedin.Points.get_balance(profile)})"
        },
        %{
          done: Profiles.count_jabs(profile) >= 1,
          route: Routes.users_index_path(socket, :index),
          name: "Business Jab someone"
        }
      ],
      2 => [
        %{
          name: "Write 1 endorsement",
          done: Profiles.count_written_endorsements(profile) >= 1,
          route: Routes.users_index_path(socket, :index)
        },
        %{
          name: "Invite someone to ShlinkedIn",
          done: Profiles.count_invites(profile) >= 1,
          route: Routes.home_index_path(socket, :new_invite)
        },
        %{
          name: "Join 1 group",
          done: length(Shlinkedin.Groups.list_profile_groups(profile)) >= 1,
          route: Routes.group_index_path(socket, :index)
        }
      ],
      3 => [
        %{
          name: "Create an Ad",
          done: Shlinkedin.Ads.count_profile_ads(profile) >= 1,
          route: Routes.home_index_path(socket, :new_ad)
        },
        %{
          name: "Write a headline",
          done: Shlinkedin.News.count_articles(profile) >= 1,
          route: Routes.home_index_path(socket, :new_article)
        },
        %{
          name: "Receive a review",
          done: length(Profiles.list_testimonials(profile.id)) >= 1,
          route: Routes.profile_show_path(socket, :show, profile.slug)
        }
      ],
      4 => [
        %{
          name:
            "Maintain a net worth of 1000 ShlinkPoints (current balance: #{
              Shlinkedin.Points.get_balance(profile)
            })",
          done: Shlinkedin.Points.get_balance(profile) |> Money.compare(Money.new(100_000)) == 1,
          route: Routes.points_index_path(socket, :index)
        },
        %{
          name: "Create a group",
          done: Shlinkedin.Groups.count_profile_creator(profile) >= 1,
          route: Routes.group_index_path(socket, :index)
        },
        %{
          name: "Win 1 Trophy",
          done: length(Profiles.list_awards(profile)) >= 1,
          route: Routes.profile_show_path(socket, :show, profile.slug)
        }
      ]
    }
  end

  def completed_level?(%Profile{} = profile, socket, level) do
    checklists(profile, socket)[level]
    |> Enum.map(& &1.done)
    |> Enum.all?()
  end

  def get_current_level(%Profile{} = profile, socket) do
    cond do
      !completed_level?(profile, socket, 0) -> 0
      !completed_level?(profile, socket, 1) -> 1
      !completed_level?(profile, socket, 2) -> 2
      !completed_level?(profile, socket, 3) -> 3
      !completed_level?(profile, socket, 4) -> 4
      true -> 5
    end
  end

  def get_current_checklist(%Profile{id: nil}, _socket) do
    level = 0

    %{
      steps: %{},
      level_number: level,
      current_level: level_names(level),
      next_level: level_names(level + 1)
    }
  end

  def get_current_checklist(%Profile{} = profile, socket) do
    level = get_current_level(profile, socket)

    %{
      steps: checklists(profile, socket)[level],
      level_number: level,
      current_level: level_names(level),
      next_level: level_names(level + 1)
    }
  end
end
