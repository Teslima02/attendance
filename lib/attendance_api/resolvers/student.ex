defmodule AttendanceApi.Resolvers.Student do
  alias AttendanceApi.Resolvers.Lecturer
  alias Attendance.Lecturers.Lecturer
  alias Attendance.Students.Student
  alias Attendance.Students
  alias Attendance.Lecturers

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
    if Attendance.Students.check_if_attendance_already_marked_for_the_student(
         current_student,
         input_params
       ) do
      {:error, "You already mark attendance"}
    else
      with lecturer_attendance <-
             Attendance.Lecturers.get_lecturer_attendance!(input_params.lecturer_attendance_id),
           course <- Attendance.Catalog.get_courses!(input_params.course_id) do
        {:ok, attendance} =
          Attendance.Students.mark_attendance(
            course,
            lecturer_attendance,
            current_student,
            input_params
          )

        {:ok, attendance}
      else
        _ -> {:error, "Error occur while marking attendance"}
      end
    end
  end
end
