defmodule AttendanceWeb.LecturerResetPasswordController do
  use AttendanceWeb, :controller

  alias Attendance.Lecturers

  plug :get_lecturer_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"lecturer" => %{"email" => email}}) do
    if lecturer = Lecturers.get_lecturer_by_email(email) do
      Lecturers.deliver_lecturer_reset_password_instructions(
        lecturer,
        &Routes.lecturer_reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Lecturers.change_lecturer_password(conn.assigns.lecturer))
  end

  # Do not log in the lecturer after reset password to avoid a
  # leaked token giving the lecturer access to the account.
  def update(conn, %{"lecturer" => lecturer_params}) do
    case Lecturers.reset_lecturer_password(conn.assigns.lecturer, lecturer_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.lecturer_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_lecturer_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if lecturer = Lecturers.get_lecturer_by_reset_password_token(token) do
      conn |> assign(:lecturer, lecturer) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
