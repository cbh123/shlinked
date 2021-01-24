defmodule Shlinkedin.Email do
  import Bamboo.Email

  def new_email(to, subject, body) do
    new_email(
      to: to,
      from: "charlie@shlinkedin.com",
      subject: subject,
      html_body: body
    )
  end

  def user_email(to, subject, body) do
    new_email(
      to: to,
      from: "charlie@shlinkedin.com",
      subject: "ShlinkedIn -- #{subject}",
      text_body: body
    )
  end
end
