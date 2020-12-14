defmodule Shlinkedin.Email do
  import Bamboo.Email
  alias Shlinkedin.Profiles.Profile

  def welcome_email do
    new_email(
      to: "charlieholtz@gmail.com",
      from: "god@shlinkedin.com",
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
  end

  def new_email(to, subject, body) do
    new_email(
      to: to,
      from: "god@shlinkedin.com",
      subject: subject,
      html_body: body
    )
  end

  def user_email(to, subject, body) do
    new_email(
      to: to,
      from: "god@shlinkedin.com",
      subject: "ShlinkedIn -- #{subject}",
      text_body: body
    )
  end

  def new_like_email(%{persona_name: name} = %Profile{}) do
    new_email(
      to: "charlieholtz@gmail.com",
      from: "god@shlinkedin.com",
      subject: "#{name} liked something",
      text_body: "#{name} liked something"
    )
  end
end
