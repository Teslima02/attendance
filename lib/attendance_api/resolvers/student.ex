defmodule AttendanceApi.Resolvers.Student do
  alias AttendanceApi.Resolvers.Lecturer
  alias Attendance.Lecturers.Lecturer
  alias Attendance.Students.Student
  alias Attendance.Lecturer_attendances
  alias Attendance.Students
  alias Attendance.Lecturers
  alias Attendance.Catalog

  def student_login(%{input: %{matric_number: matric_number, password: password}}, _context) do
    with %Student{} = student <-
           Students.get_student_by_matric_number_and_password(
             matric_number,
             password
           ),
         token <- Students.generate_student_session_token(student) do
      {:ok, %{token: Base.url_encode64(token, padding: false), student: student}}
    else
      _ -> {:error, "Incorrect matric number or password"}
    end
  end

  def get_current_student(_arg, %{context: %{current_student: current_student}}) do
    {:ok, current_student}
  end

  def get_student_courses(_input_params, %{
        context: %{current_student: current_student}
      }) do
    with courses <- Students.student_courses(current_student) do
      {:ok, courses}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting lecturer courses",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end

  def mark_attendance(%{input: input_params}, %{
        context: %{current_student: current_student}
      }) do

    #TODO: decouple this later
    cond do
      Students.check_if_attendance_already_marked_for_the_student!(
        current_student,
        input_params
      ) != nil ->
        {:error, "You already mark attendance"}

      Lecturer_attendances.check_and_update_if_attendance_time_expire!(
        input_params.lecturer_attendance_id
      ).active ==
          false ->
        {:error, "Attendance time expired"}

      Lecturer_attendances.check_and_update_if_attendance_time_expire!(
        input_params.lecturer_attendance_id
      ).active ==
        true and
        DateTime.truncate(input_params.attendance_time, :second) <
          Lecturer_attendances.check_and_update_if_attendance_time_expire!(
            input_params.lecturer_attendance_id
          ).start_date or
          DateTime.truncate(input_params.attendance_time, :second) >
            Lecturer_attendances.check_and_update_if_attendance_time_expire!(
              input_params.lecturer_attendance_id
            ).end_date ->
        {:error, "Attendance is not open yet"}

      Lecturer_attendances.check_and_update_if_attendance_time_expire!(
        input_params.lecturer_attendance_id
      ).active ==
          true ->
        Students.mark_attendance(
          Catalog.get_courses!(input_params.course_id),
          Lecturer_attendances.get_lecturer_attendance!(input_params.lecturer_attendance_id),
          current_student,
          input_params
        )
    end
  end

  def algo do
    [head | tail] = [5, 1, 4, -43, -8, 7, -7, 3, 4, 8, 9, 3, 5]

    tail
    |> Enum.filter(fn x -> x < head end)
    |> Enum.each(fn x -> IO.inspect(x) end)
  end

  def num(_n) do
    IO.read(:all) |> String.split() |> Enum.map(&String.to_integer/1)
  end
end
