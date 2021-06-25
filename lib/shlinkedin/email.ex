defmodule Shlinkedin.Email do
  import Bamboo.Email

  def new_email(to, subject, body) do
    new_email(
      to: to,
      from: "charlie@shlinkedin.com",
      subject: subject,
      html_body:
        body <>
          "<br/><br/><br/><br/><p><i>To turn off all emails, you can turn on 'Seckler Mode' in your settings <a href='https://www.shlinkedin.com/profile/live_edit'>here</a>. "
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
