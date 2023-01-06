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

  def create_lecturer_attendance(%{input: input_params}, %{
        context: %{current_lecturer: current_lecturer}
      }) do

    with semester <- Attendance.Catalog.get_semester!(input_params.semester_id),
         class <- Attendance.Catalog.get_class!(input_params.class_id),
         program <- Attendance.Catalog.get_program!(input_params.program_id),
         course <- Attendance.Catalog.get_courses!(input_params.course_id),
         {:ok, attendance} <-
           Attendance.Lecturer_attendances.create_lecturer_attendance(
             semester,
             class,
             program,
             course,
             current_lecturer,
            input_params
           ) do
      {:ok, attendance}
    else
      _ -> {:error, "Error initiating attendance"}
    end
  end
end
