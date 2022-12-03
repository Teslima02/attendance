defmodule Attendance.Lecturers do
  @moduledoc """
  The Lecturers context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Catalog.Courses
  alias Attendance.Repo

  alias Attendance.Lecturers.{Lecturer, LecturerToken, LecturerNotifier}

  ## Database getters

  # start of lecturer made
  @doc """
  Returns the list of lecturers.

  ## Examples

      iex> list_lecturers()
      [%Lecturer{}, ...]

  """
  def list_lecturers_courses(course) do
    from(l in Lecturer, where: [course_id: ^course.id], order_by: [asc: :id])
    |> Repo.all()
  end

  def list_lecturers do
    Repo.all(Lecturer) |> Repo.preload(:courses)
  end

  @doc """
  Updates a lecturer.

  ## Examples

      iex> update_lecturer(lecturer, %{field: new_value})
      {:ok, %Lecturer{}}

      iex> update_lecturer(lecturer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lecturer(%Lecturer{} = lecturer, attrs) do
    lecturer
    |> Lecturer.registration_changeset(attrs)
    |> Repo.update()
  end

  def change_assign_course_to_lecturer(%Courses{} = course, %Lecturer{} = lecturer) do
    course
    |> Repo.preload(:lecturers)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:lecturers, [lecturer | course.lecturers])
    |> Repo.update()
  end

  # def change_assign_course_to_lecturer(%Courses{} = _course, lecturer) do
  #   lecturer
  #   |> Repo.preload(:course)
  #   |> Lecturer.assign_course_to_lecturer()
  #   |> Ecto.Changeset.change()
  #   |> Ecto.Changeset.put_assoc(:course, [lecturers: lecturer])
  #   |> Repo.update()
  # end

  # def change_assign_course_to_lecturer(%Courses{} = course, %Lecturer{} = lecturer) do
  #   course = from(l in Lecturer, where: [course_id: ^course.id], order_by: [asc: l.course_id], select: {l.courses_id, l}) |> IO.inspect
  #   course
  #   |> Repo.preload(:lecturers)
  #   |> Lecturer.assign_course_to_lecturer()
  #   |> Ecto.Changeset.put_assoc(:lecturers, lecturer)
  #   # |> Lecturer.assign_course_to_lecturer()
  #   |> Repo.update()
  # end

  @doc """
  Deletes a lecturer.

  ## Examples

      iex> delete_lecturer(lecturer)
      {:ok, %Lecturer{}}

      iex> delete_lecturer(lecturer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lecturer(%Lecturer{} = lecturer) do
    Repo.delete(lecturer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lecturer changes.

  ## Examples

      iex> change_lecturer(lecturer)
      %Ecto.Changeset{data: %Lecturer{}}

  """
  def change_lecturer(%Lecturer{} = lecturer, attrs \\ %{}) do
    Lecturer.registration_changeset(lecturer, attrs)
  end

  # End of lecturer made

  @doc """
  Gets a lecturer by email.

  ## Examples

      iex> get_lecturer_by_email("foo@example.com")
      %Lecturer{}

      iex> get_lecturer_by_email("unknown@example.com")
      nil

  """
  def get_lecturer_by_email(email) when is_binary(email) do
    Repo.get_by(Lecturer, email: email)
  end

  @doc """
  Gets a lecturer by email and password.

  ## Examples

      iex> get_lecturer_by_email_and_password("foo@example.com", "correct_password")
      %Lecturer{}

      iex> get_lecturer_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_lecturer_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    lecturer = Repo.get_by(Lecturer, email: email)
    if Lecturer.valid_password?(lecturer, password), do: lecturer
  end

  @doc """
  Gets a single lecturer.

  Raises `Ecto.NoResultsError` if the Lecturer does not exist.

  ## Examples

      iex> get_lecturer!(123)
      %Lecturer{}

      iex> get_lecturer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lecturer!(id), do: Repo.get!(Lecturer, id)

  def get_lecturer_with_course!(course, id), do: Repo.get!(Lecturer, course_id: course.id, id: id)

  ## Lecturer registration

  @doc """
  Registers a lecturer.

  ## Examples

      iex> register_lecturer(%{field: value})
      {:ok, %Lecturer{}}

      iex> register_lecturer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_lecturer(admin, attrs) do
    # IO.inspect attrs
    %Lecturer{}
    |> Lecturer.registration_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lecturer changes.

  ## Examples

      iex> change_lecturer_registration(lecturer)
      %Ecto.Changeset{data: %Lecturer{}}

  """
  def change_lecturer_registration(%Lecturer{} = lecturer, attrs \\ %{}) do
    Lecturer.registration_changeset(lecturer, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the lecturer email.

  ## Examples

      iex> change_lecturer_email(lecturer)
      %Ecto.Changeset{data: %Lecturer{}}

  """
  def change_lecturer_email(lecturer, attrs \\ %{}) do
    Lecturer.email_changeset(lecturer, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_lecturer_email(lecturer, "valid password", %{email: ...})
      {:ok, %Lecturer{}}

      iex> apply_lecturer_email(lecturer, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_lecturer_email(lecturer, password, attrs) do
    lecturer
    |> Lecturer.email_changeset(attrs)
    |> Lecturer.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the lecturer email using the given token.

  If the token matches, the lecturer email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_lecturer_email(lecturer, token) do
    context = "change:#{lecturer.email}"

    with {:ok, query} <- LecturerToken.verify_change_email_token_query(token, context),
         %LecturerToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(lecturer_email_multi(lecturer, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp lecturer_email_multi(lecturer, email, context) do
    changeset =
      lecturer
      |> Lecturer.email_changeset(%{email: email})
      |> Lecturer.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:lecturer, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      LecturerToken.lecturer_and_contexts_query(lecturer, [context])
    )
  end

  @doc """
  Delivers the update email instructions to the given lecturer.

  ## Examples

      iex> deliver_update_email_instructions(lecturer, current_email, &Routes.lecturer_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(
        %Lecturer{} = lecturer,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, lecturer_token} =
      LecturerToken.build_email_token(lecturer, "change:#{current_email}")

    Repo.insert!(lecturer_token)

    LecturerNotifier.deliver_update_email_instructions(
      lecturer,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the lecturer password.

  ## Examples

      iex> change_lecturer_password(lecturer)
      %Ecto.Changeset{data: %Lecturer{}}

  """
  def change_lecturer_password(lecturer, attrs \\ %{}) do
    Lecturer.password_changeset(lecturer, attrs, hash_password: false)
  end

  @doc """
  Updates the lecturer password.

  ## Examples

      iex> update_lecturer_password(lecturer, "valid password", %{password: ...})
      {:ok, %Lecturer{}}

      iex> update_lecturer_password(lecturer, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_lecturer_password(lecturer, password, attrs) do
    changeset =
      lecturer
      |> Lecturer.password_changeset(attrs)
      |> Lecturer.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:lecturer, changeset)
    |> Ecto.Multi.delete_all(:tokens, LecturerToken.lecturer_and_contexts_query(lecturer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{lecturer: lecturer}} -> {:ok, lecturer}
      {:error, :lecturer, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_lecturer_session_token(lecturer) do
    {token, lecturer_token} = LecturerToken.build_session_token(lecturer)
    Repo.insert!(lecturer_token)
    token
  end

  @doc """
  Gets the lecturer with the given signed token.
  """
  def get_lecturer_by_session_token(token) do
    {:ok, query} = LecturerToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(LecturerToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given lecturer.

  ## Examples

      iex> deliver_lecturer_confirmation_instructions(lecturer, &Routes.lecturer_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_lecturer_confirmation_instructions(confirmed_lecturer, &Routes.lecturer_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_lecturer_confirmation_instructions(%Lecturer{} = lecturer, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if lecturer.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, lecturer_token} = LecturerToken.build_email_token(lecturer, "confirm")
      Repo.insert!(lecturer_token)

      LecturerNotifier.deliver_confirmation_instructions(
        lecturer,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Confirms a lecturer by the given token.

  If the token matches, the lecturer account is marked as confirmed
  and the token is deleted.
  """
  def confirm_lecturer(token) do
    with {:ok, query} <- LecturerToken.verify_email_token_query(token, "confirm"),
         %Lecturer{} = lecturer <- Repo.one(query),
         {:ok, %{lecturer: lecturer}} <- Repo.transaction(confirm_lecturer_multi(lecturer)) do
      {:ok, lecturer}
    else
      _ -> :error
    end
  end

  defp confirm_lecturer_multi(lecturer) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:lecturer, Lecturer.confirm_changeset(lecturer))
    |> Ecto.Multi.delete_all(
      :tokens,
      LecturerToken.lecturer_and_contexts_query(lecturer, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given lecturer.

  ## Examples

      iex> deliver_lecturer_reset_password_instructions(lecturer, &Routes.lecturer_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_lecturer_reset_password_instructions(%Lecturer{} = lecturer, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, lecturer_token} = LecturerToken.build_email_token(lecturer, "reset_password")
    Repo.insert!(lecturer_token)

    LecturerNotifier.deliver_reset_password_instructions(
      lecturer,
      reset_password_url_fun.(encoded_token)
    )
  end

  @doc """
  Gets the lecturer by reset password token.

  ## Examples

      iex> get_lecturer_by_reset_password_token("validtoken")
      %Lecturer{}

      iex> get_lecturer_by_reset_password_token("invalidtoken")
      nil

  """
  def get_lecturer_by_reset_password_token(token) do
    with {:ok, query} <- LecturerToken.verify_email_token_query(token, "reset_password"),
         %Lecturer{} = lecturer <- Repo.one(query) do
      lecturer
    else
      _ -> nil
    end
  end

  @doc """
  Resets the lecturer password.

  ## Examples

      iex> reset_lecturer_password(lecturer, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Lecturer{}}

      iex> reset_lecturer_password(lecturer, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_lecturer_password(lecturer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:lecturer, Lecturer.password_changeset(lecturer, attrs))
    |> Ecto.Multi.delete_all(:tokens, LecturerToken.lecturer_and_contexts_query(lecturer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{lecturer: lecturer}} -> {:ok, lecturer}
      {:error, :lecturer, changeset, _} -> {:error, changeset}
    end
  end
end
