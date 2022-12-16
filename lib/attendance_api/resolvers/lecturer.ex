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

  # def list_lecturers(_args, _context) do
  #   # IO.inspect current_lecturer
  #   {:ok, Lecturers.list_lecturers()}
  # end

  def list_lecturers(_args, %{context: %{current_lecturer: current_lecturer}}) do
    IO.inspect current_lecturer
    {:ok, Lecturers.list_lecturers()}
  end
end
