defmodule Shlinkedin.Profiles.ProfileNotifier do
  alias Shlinkedin.Profiles.{Profile, Endorsement, Testimonial, Notification}
  alias Shlinkedin.Timeline.{Like, Comment, Post, CommentLike}
  alias Shlinkedin.Timeline
  alias Shlinkedin.News.Vote
  alias Shlinkedin.News.Article
  alias Shlinkedin.Ads.Ad
  alias Shlinkedin.Groups.Group
  alias Shlinkedin.Groups
  alias Shlinkedin.Groups.Invite
  alias Shlinkedin.Points.Transaction
  alias Shlinkedin.Points

  @doc """
  Deliver instructions to confirm account.
  """
  def observer({:error, changeset}, _type, _from, _to), do: {:error, changeset}

  def observer({:ok, res}, type, %Profile{} = from \\ %Profile{}, %Profile{} = to \\ %Profile{}) do
    from_profile = Shlinkedin.Profiles.get_profile_by_profile_id_preload_user(from.id)
    to_profile = Shlinkedin.Profiles.get_profile_by_profile_id_preload_user(to.id)

    Points.generate_wealth(to_profile, type)

    case type do
      :post ->
        notify_comment(from_profile, to_profile, res, type)

      :comment ->
        notify_comment(from_profile, to_profile, res, type)

      :like ->
        notify_like(from_profile, to_profile, res, type)

      :comment_like ->
        notify_comment_like(from_profile, to_profile, res, type)

      :vote ->
        notify_vote(from_profile, to_profile, res, type)

      :endorsement ->
        notify_endorsement(from_profile, to_profile, res, type)

      :testimonial ->
        notify_testimonial(from_profile, to_profile, res, type)

      :sent_friend_request ->
        notify_sent_friend_request(from_profile, to_profile, type)

      :accepted_friend_request ->
        notify_accepted_friend_request(from_profile, to_profile, type)

      :featured_post ->
        notify_post_featured(to_profile, res, type)

      :new_badge ->
        notify_profile_badge(to_profile, res, type)

      :jab ->
        notify_jab(from_profile, to_profile, type)

      :ad_click ->
        notify_ad_click(from_profile, to_profile, res, type)

      :new_group_member ->
        notify_new_group_member(from_profile, res, type)

      :sent_group_invite ->
        notify_group_invite(from_profile, to_profile, res, type)

      :sent_transaction ->
        notify_sent_points(from_profile, to_profile, res, type)
    end

    {:ok, res}
  end

  def notify_group_invite(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Invite{} = invite,
        type
      ) do
    group = Groups.get_group!(invite.group_id)

    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    #{from_profile.persona_name} has invited you the #{group.privacy_type} group they are in, "#{
      group.title
    }." To accept or reject their invite,
    you can <a href="https://www.shlinkedin.com/groups/#{group.id}">click here.</a>

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      group_id: group.id,
      type: "group_invite",
      action: "invited you to join #{group.title}",
      body: ""
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "#{from_profile.persona_name} invited you to join #{group.title}",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_new_group_member(%Profile{} = new_profile, %Group{} = group, type) do
    for member <- Shlinkedin.Groups.list_members(group) do
      if member.profile_id != new_profile.id do
        Shlinkedin.Profiles.create_notification(%Notification{
          from_profile_id: new_profile.id,
          to_profile_id: member.profile_id,
          type: "new_group_member",
          group_id: group.id,
          action: "joined a group you are in: ",
          body: "#{group.title}. Welcome them!"
        })
      end
    end
  end

  def notify_jab(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        type
      ) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    #{from_profile.persona_name} has business jabbed you! Time to take
    some corporate revenge and <a href="https://www.shlinkedin.com/sh/#{from_profile.slug}">jab them back.</a>

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      type: "jab",
      action: "business jabbed you!",
      body: "Get some corporate revenge and jab them back!"
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "#{from_profile.persona_name} business jabbed you!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_sent_points(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Transaction{} = transaction,
        type
      ) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    <a href="https://www.shlinkedin.com/sh/#{from_profile.slug}">#{from_profile.persona_name}</a>
    has sent you #{transaction.amount}! You now have a new worth of #{to_profile.points}.

    <br/>
    <br/>
    Transaction Memo: #{transaction.note}

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      type: "sent_points",
      action: "sent you #{transaction.amount}.",
      body: "Memo: #{transaction.note}"
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "#{from_profile.persona_name} has sent you ShlinkPoints!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_sent_friend_request(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        type
      ) do
    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      type: "pending_shlink",
      action: "has sent you a Shlink request!",
      body: ""
    })

    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    <p>Hi #{from_profile.persona_name} / #{from_profile.real_name} has sent you a Shlink request. You can accept it
    <a href="https://www.shlinkedin.com/sh/#{to_profile.slug}">here.</a>

    Time to think of some ice-breakers, like:</p>

    <ul>
    #{for line <- friend_request_text(), do: "<li>#{line}</li>"}
    </ul>

    <p>Happy shlinking!</p>

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "#{from_profile.persona_name} has sent you a shlink request!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  defp friend_request_text() do
    [
      [
        "What’s the secret to your success?",
        "What are your business interests?",
        "How did your last relationship end?",
        "Whose fault was it?",
        "Do you still think about it?"
      ],
      [
        "Where do you see yourself in 100 years?",
        "If you could talk to yourself as a 10 year, or another 10 year old, uh, nevermind."
      ],
      [
        "How many conferences do you attend per year?",
        "What’s better, spiders or scorpions?"
      ],
      [
        "How long have you been in your line of work?",
        "How do you keep employees motivated?",
        "Do you remember what it was like to have dreams?"
      ],
      [
        "What’s cookin’, good lookin’?",
        "Please don’t tell HR I said that, I really didn’t mean anything by it."
      ],
      [
        "Hey, do you need friends?",
        "Should we hang out sometime?",
        "What are you doing this weekend?",
        "Do you want to come to my birthday party?"
      ],
      [
        "What’s your industry’s best kept secret?",
        "What do you know about business that no one else does?",
        "Where is the treasure? WHERE ARE YOU HIDING THE TREASURE?"
      ],
      [
        "Where do you go at night?",
        "Do you ever have nightmares?",
        "Are you ever suspicious of people?"
      ]
    ]
    |> Enum.random()
  end

  def notify_accepted_friend_request(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        type
      ) do
    body = """

    Hi #{from_profile.persona_name},

    <br/>
    <br/>

    <p>Congratulations! #{to_profile.persona_name} / #{to_profile.real_name} has accepted your Shlink request. Your reward is +#{
      Points.get_rule_amount(type)
    }. Time to ask them something personal, like:</p>

    <ul>
    #{for line <- friend_request_text(), do: "<li>#{line}</li>"}
    </ul>

    <p>Time to get the conversation going!</p>

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: to_profile.id,
      to_profile_id: from_profile.id,
      type: "accepted_shlink",
      action: "has accepted your Shlink request! +#{Points.get_rule_amount(type)}",
      body: ""
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        from_profile.user.email,
        "#{to_profile.persona_name} has accepted your Shlink request!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_endorsement(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Endorsement{} = endorsement,
        type
      ) do
    body = """

    Congratulations #{to_profile.persona_name},

    <br/>
    <br/>

    <a href="https://www.shlinkedin.com/sh/#{from_profile.slug}">#{from_profile.persona_name}</a> has endorsed you for "#{
      endorsement.body
    }"! Your reward is +#{Points.get_rule_amount(type)}.

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "endorsement",
        action: "endorsed you for",
        body: "#{endorsement.body}. +#{Points.get_rule_amount(type)}"
      })

      if to_profile.unsubscribed == false do
        Shlinkedin.Email.new_email(to_profile.user.email, "You've been endorsed!", body)
        |> Shlinkedin.Mailer.deliver_later()
      end
    end
  end

  def notify_ad_click(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Shlinkedin.Ads.Click{} = click,
        type
      ) do
    ad = Shlinkedin.Ads.get_ad!(click.ad_id)

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "ad_click",
        action: "clicked on your ad for",
        body: "#{ad.company}. +#{Points.get_rule_amount(type)}"
      })
    end
  end

  def notify_testimonial(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Testimonial{} = testimonial,
        type
      ) do
    body = """

    Wow #{to_profile.persona_name},

    <br/>
    <br/>

    <a href="https://www.shlinkedin.com/sh/#{from_profile.slug}">#{from_profile.persona_name}</a> has written a #{
      testimonial.rating
    }/5 star review for you. Check it out
    <a href="shlinked.herokuapp.com/sh/#{to_profile.slug}">on your profile.</a>. Your reward is +#{
      Points.get_rule_amount(type)
    }

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "testimonial",
        action: "wrote you a review: ",
        body: "#{testimonial.body}"
      })

      if to_profile.unsubscribed == false do
        Shlinkedin.Email.new_email(
          to_profile.user.email,
          "#{from_profile.persona_name} has given you #{testimonial.rating}/5 stars! +#{
            Points.get_rule_amount(type)
          }",
          body
        )
        |> Shlinkedin.Mailer.deliver_later()
      end
    end
  end

  def notify_like(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Like{} = like,
        type
      ) do
    # get notification where to_profile is same and post id is same,
    # and then update action to "and [] also did."
    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "like",
        post_id: like.post_id,
        action: "reacted \"#{like.like_type}\" to your post. +#{Points.get_rule_amount(type)}"
      })
    end
  end

  def notify_comment_like(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %CommentLike{} = like,
        type
      ) do
    # get notification where to_profile is same and post id is same,
    # and then update action to "and [] also did."
    # could be optimized by one query
    comment = Timeline.get_comment!(like.comment_id)
    post = Timeline.get_post!(comment.post_id)

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "like",
        post_id: post.id,
        action: "reacted \"#{like.like_type}\" to your comment. +#{Points.get_rule_amount(type)}"
      })
    end
  end

  def notify_vote(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Vote{} = vote,
        type
      ) do
    # get notification where to_profile is same and post id is same,
    # and then update action to "and [] also did."
    if from_profile.id != to_profile.id and
         Shlinkedin.News.is_first_vote_on_article?(from_profile, %Article{id: vote.article_id}) do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "vote",
        article_id: vote.article_id,
        action: "clapped your headline! +#{Points.get_rule_amount(type)}"
      })
    end
  end

  def notify_post_featured(%Profile{} = to_profile, %Post{} = post, type) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    We are excited to inform you that your post has been awarded
     <a href="https://www.shlinkedin.com/posts/#{post.id}">post of the day!</a>!!!
     Your reward is +#{Points.get_rule_amount(type)}.

    <br/>
    <br/>
    Thanks, <br/>
    ShlinkTeam

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: 3,
      to_profile_id: to_profile.id,
      type: "featured",
      post_id: post.id,
      action: "has decided to award you post of the day! +#{Points.get_rule_amount(type)}."
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "You've been awarded post of the day!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_profile_badge(%Profile{} = to_profile, badge, type) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    You have been awarded the #{badge} badge!!! It's been added to your trophy case on your profile.

    <br/>
    <br/>
    Congrats! <br/>
    ShlinkTeam

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: 3,
      to_profile_id: to_profile.id,
      type: "new_badge",
      action: "has awarded you the #{badge} badge! It's been added to your trophy case."
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "You got an award!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_post(
        %Profile{} = from_profile,
        %Profile{} = _to_profile,
        %Post{} = post,
        type
      ) do
    for username <- post.profile_tags do
      to_profile = Shlinkedin.Profiles.get_profile_by_username(username)

      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "post_tag",
        post_id: post.id,
        action: "tagged you in a post: ",
        body: "#{post.body}"
      })
    end
  end

  def notify_comment(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Comment{} = comment,
        type
      ) do
    for username <- comment.profile_tags do
      to_profile = Shlinkedin.Profiles.get_profile_by_username(username)

      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "comment",
        post_id: comment.post_id,
        action: "tagged you in a comment: ",
        body: "#{comment.body}"
      })
    end

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "comment",
        post_id: comment.post_id,
        action: "commented on your post: ",
        body: "#{comment.body}"
      })
    end
  end
end
