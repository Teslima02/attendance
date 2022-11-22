defmodule AttendanceWeb.LecturerConfirmationController do
  use AttendanceWeb, :controller

  alias Attendance.Lecturers

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"lecturer" => %{"email" => email}}) do
    if lecturer = Lecturers.get_lecturer_by_email(email) do
      Lecturers.deliver_lecturer_confirmation_instructions(
        lecturer,
        &Routes.lecturer_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the lecturer after confirmation to avoid a
  # leaked token giving the lecturer access to the account.
  def update(conn, %{"token" => token}) do
    case Lecturers.confirm_lecturer(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Lecturer confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current lecturer and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the lecturer themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_lecturer: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Lecturer confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
