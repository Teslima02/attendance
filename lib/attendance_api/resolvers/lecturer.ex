defmodule AttendanceApi.Resolvers.Lecturer do
  alias AttendanceApi.Resolvers.Lecturer
  alias Attendance.Lecturers.Lecturer
  alias Attendance.Lecturers

  def lecturer_login(%{input: %{matric_number: matric_number, password: password}}, _context) do
    with %Lecturers.Lecturer{} = lecturer <-
           Attendance.Lecturers.get_lecturer_by_matric_number_and_password(
             matric_number,
             password
           ),
         token <- Lecturers.generate_lecturer_session_token(lecturer) do
      {:ok, %{token: Base.url_encode64(token, padding: false), lecturer: lecturer}}
    else
      _ -> {:error, "Incorrect matric number or password"}
    end
  end

  def list_lecturers(_args, %{context: %{current_lecturer: _current_lecturer}}) do
    {:ok, Lecturers.list_lecturers()}
  end

  def get_current_lecturer(_arg, %{context: %{current_lecturer: current_lecturer}}) do
    {:ok, current_lecturer}
  end

  def get_lecturer_courses(%{input: _input_params}, %{
        context: %{current_lecturer: current_lecturer}
      }) do
    with [courses] <- Attendance.Lecturers.lecturer_courses(current_lecturer) do
      {:ok, courses}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting lecturer courses",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end
end
