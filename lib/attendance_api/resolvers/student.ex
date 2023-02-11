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
    with student <-
           Attendance.Students.current_student!(current_student.id) do
      {:ok, student}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting current student details",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}

      {:error, error} ->
        {:error, message: "current student details not found", details: error}
    end
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
    # TODO: decouple this later
    cond do
      Students.check_if_attendance_already_marked_for_the_student!(
        current_student,
        input_params.lecturer_attendance_id
      ) != nil ->
        {:error, "You already mark attendance"}

      Lecturer_attendances.check_and_update_if_attendance_time_expire!(
        input_params.lecturer_attendance_id
      ).active ==
          false ->
        {:error, "Attendance time expired"}

      (Lecturer_attendances.check_and_update_if_attendance_time_expire!(
         input_params.lecturer_attendance_id
       ).active ==
         true and
         DateTime.truncate(input_params.attendance_time, :second) <
           Lecturer_attendances.check_and_update_if_attendance_time_expire!(
             input_params.lecturer_attendance_id
           ).start_date) or
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

  def get_current_attendances(%{input: input_params}, %{
        context: %{current_student: _current_student}
      }) do
    with _ <- Lecturer_attendances.update_lecturer_attendances_list(),
         attendance <- Students.paginate_current_attendance(input_params) do
      attendance
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting current attendances",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end

  def get_student_attendances(%{input: input_params}, %{
        context: %{current_student: _current_student}
      }) do
    with {:ok, attendances} <-
           Attendance.Students.paginate_attendance(input_params) do
      {:ok, attendances}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting attendances",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end

  def notification_history(%{input: input_params}, %{
        context: %{current_student: _current_student}
      }) do
    with {:ok, notifications} <-
           Attendance.Notifications.paginate_notification(input_params) do
      {:ok, notifications}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting notifications",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end

  def get_student_current_period(_args, %{
        context: %{current_student: current_student}
      }) do
    with {:ok, period} <-
           Attendance.Timetables.student_current_period(current_student) do
      {:ok, period}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting notifications",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}

      {:error, error} ->
        {:error, message: "No current period or today is weekend", details: error}
    end
  end
end
