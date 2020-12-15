defmodule Shlinkedin.Profiles.ProfileNotifier do
  alias Shlinkedin.Profiles.Profile
  alias Shlinkedin.Profiles.Endorsement
  alias Shlinkedin.Profiles.Testimonial

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
    end

    {:ok, res}
  end

  def observer({:error, error}, _from, _to, _type), do: error

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

    Shlinkedin.Email.new_email(
      to_profile.user.email,
      "#{from_profile.persona_name} has given you #{testimonial.rating}/5 stars!",
      body
    )
    |> Shlinkedin.Mailer.deliver_later()
  end
end
