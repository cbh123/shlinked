defmodule Shlinkedin.Profiles.ProfileNotifier do
  @doc """
  Deliver instructions to confirm account.
  """
  def notify_endorsement(from_profile, to_profile, endorsement) do
    body = """

    Congratulations #{to_profile.persona_name},

    <br/>
    <br/>

    <a href="shlinked.herokuapp.com/sh/#{from_profile.slug}">#{from_profile.persona_name}</a> has endorsed you for "#{
      endorsement
    }".
    That's so nice of them. What a treat.

    <br/>
    <br/>
    Thanks, <br/>
    God

    """

    Shlinkedin.Email.new_email(to_profile.user.email, "You've been endorsed!", body)
    |> Shlinkedin.Mailer.deliver_later()
  end
end
