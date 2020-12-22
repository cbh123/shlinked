defmodule Shlinkedin.Profiles.ProfileNotifier do
  alias Shlinkedin.Profiles.{Profile, Endorsement, Testimonial, Notification}
  alias Shlinkedin.Timeline.{Like, Comment, Post}

  @doc """
  Deliver instructions to confirm account.
  """
  def observer({:ok, res}, type, %Profile{} = from \\ %Profile{}, %Profile{} = to \\ %Profile{}) do
    from_profile = Shlinkedin.Profiles.get_profile_by_profile_id_preload_user(from.id)
    to_profile = Shlinkedin.Profiles.get_profile_by_profile_id_preload_user(to.id)

    case type do
      :comment ->
        notify_comment(from_profile, to_profile, res)

      :like ->
        notify_like(from_profile, to_profile, res)

      :endorsement ->
        notify_endorsement(from_profile, to_profile, res)

      :testimonial ->
        notify_testimonial(from_profile, to_profile, res)

      :sent_friend_request ->
        notify_sent_friend_request(from_profile, to_profile)

      :accepted_friend_request ->
        notify_accepted_friend_request(from_profile, to_profile)

      :featured_post ->
        notify_post_featured(to_profile, res)
    end

    {:ok, res}
  end

  def observer({:error, error}, _from, _to, _type), do: error

  def notify_sent_friend_request(
        %Profile{} = from_profile,
        %Profile{} = to_profile
      ) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    #{from_profile.persona_name} has sent you a shlink request. You can
    respond to it on your <a href="shlinked.herokuapp.com/shlinks">my shlinks</a> page.


    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      type: "pending_shlink",
      action: "has sent you a Shlink request!",
      body: ""
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        to_profile.user.email,
        "#{from_profile.persona_name} has sent you a Shlink request!",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_accepted_friend_request(
        %Profile{} = from_profile,
        %Profile{} = to_profile
      ) do
    body = """

    Hi #{from_profile.persona_name},

    <br/>
    <br/>

    Congratulations! #{to_profile.persona_name} has accepted your Shlink request. Why not <a href="shlinked.herokuapp.com/sh/#{
      to_profile.slug
    }">business jab them in return?</a>

    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: to_profile.id,
      to_profile_id: from_profile.id,
      type: "accepted_shlink",
      action: "has accepted your Shlink request!",
      body: ""
    })

    if to_profile.unsubscribed == false do
      Shlinkedin.Email.new_email(
        from_profile.user.email,
        "#{to_profile.persona_name} has accepted your Shlink request! Shlinkpoints +1",
        body
      )
      |> Shlinkedin.Mailer.deliver_later()
    end
  end

  def notify_endorsement(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Endorsement{} = endorsement
      ) do
    body = """

    Congratulations #{to_profile.persona_name},

    <br/>
    <br/>

    <a href="shlinked.herokuapp.com/sh/#{from_profile.slug}">#{from_profile.persona_name}</a> has endorsed you for "#{
      endorsement.body
    }"!

    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "endorsement",
        action: "endorsed you for",
        body: "#{endorsement.body}"
      })

      if to_profile.unsubscribed == false do
        Shlinkedin.Email.new_email(to_profile.user.email, "You've been endorsed!", body)
        |> Shlinkedin.Mailer.deliver_later()
      end
    end
  end

  def notify_testimonial(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Testimonial{} = testimonial
      ) do
    body = """

    Wow #{to_profile.persona_name},

    <br/>
    <br/>

    <a href="shlinked.herokuapp.com/sh/#{from_profile.slug}">#{from_profile.persona_name}</a> has written a #{
      testimonial.rating
    }/5 star review for you. Check it out
    <a href="shlinked.herokuapp.com/sh/#{to_profile.slug}">on your profile.</a>

    <br/>
    <br/>
    Thanks, <br/>
    God

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
          "#{from_profile.persona_name} has given you #{testimonial.rating}/5 stars!",
          body
        )
        |> Shlinkedin.Mailer.deliver_later()
      end
    end
  end

  def notify_like(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Like{} = like
      ) do
    # get notification where to_profile is same and post id is same,
    # and then update action to "and [] also did."
    if from_profile.id != to_profile.id and
         Shlinkedin.Timeline.is_first_like_on_post?(from_profile, %Post{id: like.post_id}) do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "like",
        post_id: like.post_id,
        action: "reacted \"#{like.like_type}\" to your post."
      })
    end
  end

  def notify_post_featured(%Profile{} = to_profile, %Post{} = post) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    We are excited to inform you that your post has been awarded
     <a href="shlinked.herokuapp.com/posts/#{post.id}">post of the day!</a>!!!
     +100 ShlinkPoints.

    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: 3,
      to_profile_id: to_profile.id,
      type: "featured",
      post_id: post.id,
      action: "has decided to award you post of the day!"
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

  def notify_comment(
        %Profile{} = from_profile,
        %Profile{} = to_profile,
        %Comment{} = comment
      ) do
    body = """

    Hi #{to_profile.persona_name},

    <br/>
    <br/>

    Great news: #{from_profile.persona_name} has commented on your
     <a href="shlinked.herokuapp.com/posts/#{comment.post_id}">post.</a>

    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    if from_profile.id != to_profile.id do
      Shlinkedin.Profiles.create_notification(%Notification{
        from_profile_id: from_profile.id,
        to_profile_id: to_profile.id,
        type: "comment",
        post_id: comment.post_id,
        action: "commented on your post: ",
        body: "#{comment.body}"
      })

      if to_profile.unsubscribed == false do
        Shlinkedin.Email.new_email(
          to_profile.user.email,
          "Your post is getting traction!",
          body
        )
        |> Shlinkedin.Mailer.deliver_later()
      end
    end
  end
end
