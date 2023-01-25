defmodule Attendance.Students do
  @moduledoc """
  The Students context.
  """
  import Ecto.Query, warn: false
  alias Attendance.Lecturer_attendances.{Student_attendance, Lecturer_attendance}
  alias Attendance.Students.Student
  alias Attendance.Catalog.Course
  alias Attendance.Catalog
  alias Attendance.Repo

  alias Attendance.Students.{Student, StudentToken, StudentNotifier}

  import Saas.Helpers, only: [sort: 1, paginate: 4, stringify_map_key: 1]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  def paginate_current_attendance(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:current_attendances),
             stringify_map_key(params[:attendance]) || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_current_attendance(filter, params) do
      {:ok,
       %{
         attendances: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_current_attendance(filter, params) do
    Lecturer_attendance
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> preload([:course])
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:current_attendances) do
    defconfig do
      text(:program_id)
      text(:class_id)
      text(:course_id)
      text(:lecturer_id)
      boolean(:active)
      datetime([:start_date, :end_date])
    end
  end

  ## Database getters

  @doc """
  Gets a student by email.

  ## Examples

      iex> get_student_by_email("foo@example.com")
      %Student{}

      iex> get_student_by_email("unknown@example.com")
      nil

  """
  def get_student_by_email(email) when is_binary(email) do
    Repo.get_by(Student, email: email)
  end

  @doc """
  Gets a student by email and password.

  ## Examples

      iex> get_student_by_email_and_password("foo@example.com", "correct_password")
      %Student{}

      iex> get_student_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_student_by_matric_number_and_password(matric_number, password)
      when is_binary(matric_number) and is_binary(password) do
    student = Repo.get_by(Student, matric_number: matric_number) |> Repo.preload([:class, :program])
    if Student.valid_password?(student, password), do: student
  end

  @doc """
  Gets a single student.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

      iex> get_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student!(id), do: Repo.get!(Student, id)

  ## Student registration

  @doc """
  Registers a student.

  ## Examples

      iex> register_student(%{field: value})
      {:ok, %Student{}}

      iex> register_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_student(admin, program, class, attrs) do
    %Student{}
    |> Student.registration_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Ecto.Changeset.put_assoc(:class, class)
    |> Ecto.Changeset.put_assoc(:program, program)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student changes.

  ## Examples

      iex> change_student_registration(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student_registration(%Student{} = student, attrs \\ %{}) do
    Student.registration_changeset(student, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the student email.

  ## Examples

      iex> change_student_email(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student_email(student, attrs \\ %{}) do
    Student.email_changeset(student, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_student_email(student, "valid password", %{email: ...})
      {:ok, %Student{}}

      iex> apply_student_email(student, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_student_email(student, password, attrs) do
    student
    |> Student.email_changeset(attrs)
    |> Student.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the student email using the given token.

  If the token matches, the student email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_student_email(student, token) do
    context = "change:#{student.email}"

    with {:ok, query} <- StudentToken.verify_change_email_token_query(token, context),
         %StudentToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(student_email_multi(student, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp student_email_multi(student, email, context) do
    changeset =
      student
      |> Student.email_changeset(%{email: email})
      |> Student.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:student, changeset)
    |> Ecto.Multi.delete_all(:tokens, StudentToken.student_and_contexts_query(student, [context]))
  end

  @doc """
  Delivers the update email instructions to the given student.

  ## Examples

      iex> deliver_update_email_instructions(student, current_email, &Routes.student_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Student{} = student, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, student_token} =
      StudentToken.build_email_token(student, "change:#{current_email}")

    Repo.insert!(student_token)

    StudentNotifier.deliver_update_email_instructions(
      student,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the student password.

  ## Examples

      iex> change_student_password(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student_password(student, attrs \\ %{}) do
    Student.password_changeset(student, attrs, hash_password: false)
  end

  @doc """
  Updates the student password.

  ## Examples

      iex> update_student_password(student, "valid password", %{password: ...})
      {:ok, %Student{}}

      iex> update_student_password(student, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_student_password(student, password, attrs) do
    changeset =
      student
      |> Student.password_changeset(attrs)
      |> Student.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:student, changeset)
    |> Ecto.Multi.delete_all(:tokens, StudentToken.student_and_contexts_query(student, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{student: student}} -> {:ok, student}
      {:error, :student, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_student_session_token(student) do
    {token, student_token} = StudentToken.build_session_token(student)
    Repo.insert!(student_token)
    token
  end

  @doc """
  Gets the student with the given signed token.
  """
  def get_student_by_session_token(token) do
    {:ok, query} = StudentToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(StudentToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given student.

  ## Examples

      iex> deliver_student_confirmation_instructions(student, &Routes.student_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_student_confirmation_instructions(confirmed_student, &Routes.student_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_student_confirmation_instructions(%Student{} = student, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if student.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, student_token} = StudentToken.build_email_token(student, "confirm")
      Repo.insert!(student_token)

      StudentNotifier.deliver_confirmation_instructions(
        student,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Confirms a student by the given token.

  If the token matches, the student account is marked as confirmed
  and the token is deleted.
  """
  def confirm_student(token) do
    with {:ok, query} <- StudentToken.verify_email_token_query(token, "confirm"),
         %Student{} = student <- Repo.one(query),
         {:ok, %{student: student}} <- Repo.transaction(confirm_student_multi(student)) do
      {:ok, student}
    else
      _ -> :error
    end
  end

  defp confirm_student_multi(student) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:student, Student.confirm_changeset(student))
    |> Ecto.Multi.delete_all(
      :tokens,
      StudentToken.student_and_contexts_query(student, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given student.

  ## Examples

      iex> deliver_student_reset_password_instructions(student, &Routes.student_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_student_reset_password_instructions(%Student{} = student, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, student_token} = StudentToken.build_email_token(student, "reset_password")
    Repo.insert!(student_token)

    StudentNotifier.deliver_reset_password_instructions(
      student,
      reset_password_url_fun.(encoded_token)
    )
  end

  @doc """
  Gets the student by reset password token.

  ## Examples

      iex> get_student_by_reset_password_token("validtoken")
      %Student{}

      iex> get_student_by_reset_password_token("invalidtoken")
      nil

  """
  def get_student_by_reset_password_token(token) do
    with {:ok, query} <- StudentToken.verify_email_token_query(token, "reset_password"),
         %Student{} = student <- Repo.one(query) do
      student
    else
      _ -> nil
    end
  end

  @doc """
  Resets the student password.

  ## Examples

      iex> reset_student_password(student, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Student{}}

      iex> reset_student_password(student, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_student_password(student, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:student, Student.password_changeset(student, attrs))
    |> Ecto.Multi.delete_all(:tokens, StudentToken.student_and_contexts_query(student, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{student: student}} -> {:ok, student}
      {:error, :student, changeset, _} -> {:error, changeset}
    end
  end

  alias Attendance.Students.Student

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students(%{"class_id" => class_id}) do
    query = from s in Student, where: s.class_id == ^class_id
    Repo.all(query)
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student(%Student{} = student, attrs) do
    student
    |> Student.registration_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student changes.

  ## Examples

      iex> change_student(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student(%Student{} = student, attrs \\ %{}) do
    Student.registration_changeset(student, attrs)
  end

  def student_courses(current_student) do
    query =
      from c in Course,
        where:
          c.semester_id == ^Catalog.get_current_session!().id and
            c.class_id == ^current_student.class_id

    Repo.all(query)
  end

  def mark_attendance(course, lecturer_attendance, current_student, attrs) do
    %Student_attendance{}
    |> Student_attendance.changeset(Enum.into(attrs, %{status: true}))
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Ecto.Changeset.put_assoc(:student, current_student)
    |> Ecto.Changeset.put_assoc(:lecturer_attendance, lecturer_attendance)
    |> Repo.insert()
  end

  def check_if_attendance_already_marked_for_the_student!(current_student, lecturer_attendance_id) do
    query =
      from s in Student_attendance,
        where:
          s.lecturer_attendance_id == ^lecturer_attendance_id and
            s.student_id == ^current_student.id

    Repo.one(query)
  end

  def paginate_attendance(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
            filter_config_student(:attendances),
             stringify_map_key(params[:attendance]) || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_attendance(filter, params) do
      {:ok,
       %{
         attendances: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_attendance(filter, params) do
    Student_attendance
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> preload([:lecturer_attendance, :course, :student])
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config_student(:attendances) do
    defconfig do
      text(:lecturer_attendance_id)
      text(:course_id)
      text(:student_id)
      datetime(:attendance_time)
      boolean(:status)
    end
  end
end
