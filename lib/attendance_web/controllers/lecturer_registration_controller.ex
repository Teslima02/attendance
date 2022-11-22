defmodule AttendanceWeb.LecturerRegistrationController do
  use AttendanceWeb, :controller

  alias Attendance.Lecturers
  alias Attendance.Lecturers.Lecturer
  alias AttendanceWeb.LecturerAuth

  def new(conn, _params) do
    changeset = Lecturers.change_lecturer_registration(%Lecturer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"lecturer" => lecturer_params}) do
    case Lecturers.register_lecturer('', lecturer_params) do
      {:ok, lecturer} ->
        {:ok, _} =
          Lecturers.deliver_lecturer_confirmation_instructions(
            lecturer,
            &Routes.lecturer_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Lecturer created successfully.")
        |> LecturerAuth.log_in_lecturer(lecturer)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
