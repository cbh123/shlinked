defmodule Shlinkedin.Accounts.UserNotifier do
  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    body = """


    Hi #{user.email},

    Danke for joining ShlinkedIn! As an elite early member, you will now live forever. Stay tuned for updates.




    You can confirm your ShlinkedIn account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    Thanks,
    God

    """

    Shlinkedin.Email.user_email(user.email, "Confirm Account", body)
    |> Shlinkedin.Mailer.deliver_later()

    {:ok, %{to: user.email, body: body}}
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    body = """


    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    """

    Shlinkedin.Email.user_email(user.email, "Reset Password", body)
    |> Shlinkedin.Mailer.deliver_later()

    {:ok, %{to: user.email, body: body}}
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    body = """


    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    """

    Shlinkedin.Email.user_email(user.email, "Update Email", body)
    |> Shlinkedin.Mailer.deliver_later()

    {:ok, %{to: user.email, body: body}}
  end
end
