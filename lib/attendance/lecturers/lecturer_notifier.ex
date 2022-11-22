defmodule Attendance.Lecturers.LecturerNotifier do
  import Swoosh.Email

  alias Attendance.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Attendance", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(lecturer, url) do
    deliver(lecturer.email, "Confirmation instructions", """

    ==============================

    Hi #{lecturer.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a lecturer password.
  """
  def deliver_reset_password_instructions(lecturer, url) do
    deliver(lecturer.email, "Reset password instructions", """

    ==============================

    Hi #{lecturer.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a lecturer email.
  """
  def deliver_update_email_instructions(lecturer, url) do
    deliver(lecturer.email, "Update email instructions", """

    ==============================

    Hi #{lecturer.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
