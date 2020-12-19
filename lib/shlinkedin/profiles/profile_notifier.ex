defmodule Shlinkedin.Profiles.ProfileNotifier do
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.Endorsement
  alias Shlinkedin.Profiles.Testimonial
  alias Shlinkedin.Profiles.Notification

  @doc """
  Deliver instructions to confirm account.
  """
  def observer({:ok, res}, %Profile{} = from, %Profile{} = to, type) do
    from_profile = Shlinkedin.Profiles.get_profile_by_profile_id_preload_user(from.id)
    to_profile = Shlinkedin.Profiles.get_profile_by_profile_id_preload_user(to.id)

    case type do
      :endorsement ->
        notify_endorsement(from_profile, to_profile, res)

      :testimonial ->
        notify_testimonial(from_profile, to_profile, res)

      :sent_friend_request ->
        notify_sent_friend_request(from_profile, to_profile)

      :accepted_friend_request ->
        notify_accepted_friend_request(from_profile, to_profile)
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

    Shlinkedin.Email.new_email(
      to_profile.user.email,
      "#{from_profile.persona_name} has sent you a Shlink request!",
      body
    )
    |> Shlinkedin.Mailer.deliver_later()
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

    Shlinkedin.Email.new_email(
      from_profile.user.email,
      "#{to_profile.persona_name} has accepted your Shlink request! Shlinkpoints +1",
      body
    )
    |> Shlinkedin.Mailer.deliver_later()
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

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      type: "endorsement",
      action: "endorsed you for",
      body: "#{endorsement.body}"
    })

    Shlinkedin.Email.new_email(to_profile.user.email, "You've been endorsed!", body)
    |> Shlinkedin.Mailer.deliver_later()
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
    }/5 star testimony for you. Check it out
    <a href="shlinked.herokuapp.com/sh/#{to_profile.slug}">on your profile.</a>

    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    Shlinkedin.Profiles.create_notification(%Notification{
      from_profile_id: from_profile.id,
      to_profile_id: to_profile.id,
      type: "testimonial",
      action: "wrote you a testimonial: ",
      body: "#{testimonial.body}"
    })

    Shlinkedin.Email.new_email(
      to_profile.user.email,
      "#{from_profile.persona_name} has given you #{testimonial.rating}/5 stars!",
      body
    )
    |> Shlinkedin.Mailer.deliver_later()
  end
end
