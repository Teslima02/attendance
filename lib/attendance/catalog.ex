defmodule Attendance.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Catalog.Program

  @doc """
  Returns the list of programs.

  ## Examples

      iex> list_programs()
      [%Program{}, ...]

  """
  def list_programs(%{"id" => id} = _params) do
    query = from p in Program, where: p.session_id == ^id
    Repo.all(query) |> Repo.preload(:admin)
  end

  @doc """
  Gets a single program.

  Raises `Ecto.NoResultsError` if the Program does not exist.

  ## Examples

      iex> get_program!(123)
      %Program{}

      iex> get_program!(456)
      ** (Ecto.NoResultsError)

  """
  def get_program!(id), do: Repo.get!(Program, id) |> Repo.preload(:admin)

  @doc """
  Creates a program.

  ## Examples

      iex> create_program(%{field: value})
      {:ok, %Program{}}

      iex> create_program(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_program(admin, session, attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Ecto.Changeset.put_assoc(:session, session)
    |> Repo.insert()
  end

  @doc """
  Updates a program.

  ## Examples

      iex> update_program(program, %{field: new_value})
      {:ok, %Program{}}

      iex> update_program(program, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_program(%Program{} = program, attrs) do
    program
    |> Program.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a program.

  ## Examples

      iex> delete_program(program)
      {:ok, %Program{}}

      iex> delete_program(program)
      {:error, %Ecto.Changeset{}}

  """
  def delete_program(%Program{} = program) do
    Repo.delete(program)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking program changes.

  ## Examples

      iex> change_program(program)
      %Ecto.Changeset{data: %Program{}}

  """
  def change_program(%Program{} = program, attrs \\ %{}) do
    Program.changeset(program, attrs)
  end

  alias Attendance.Catalog.Session

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(admin, attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Repo.insert()
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end

  alias Attendance.Catalog.Semester

  @doc """
  Returns the list of semesters.

  ## Examples

      iex> list_semesters()
      [%Semester{}, ...]

  """
  def list_semesters(
        %{"class_id" => class_id, "program_id" => _program_id, "session_id" => _session_id} =
          _params
      ) do
    query = from s in Semester, where: s.class_id == ^class_id
    Repo.all(query) |> Repo.preload(:admin)
  end

  @doc """
  Gets a single semester.

  Raises `Ecto.NoResultsError` if the Semester does not exist.

  ## Examples

      iex> get_semester!(123)
      %Semester{}

      iex> get_semester!(456)
      ** (Ecto.NoResultsError)

  """
  def get_semester!(id), do: Repo.get!(Semester, id)

  @doc """
  Creates a semester.

  ## Examples

      iex> create_semester(%{field: value})
      {:ok, %Semester{}}

      iex> create_semester(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_semester(admin, session, program, class, attrs \\ %{}) do
    %Semester{}
    |> Semester.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Ecto.Changeset.put_assoc(:session, session)
    |> Ecto.Changeset.put_assoc(:program, program)
    |> Ecto.Changeset.put_assoc(:class, class)
    |> Repo.insert()
  end

  @doc """
  Updates a semester.

  ## Examples

      iex> update_semester(semester, %{field: new_value})
      {:ok, %Semester{}}

      iex> update_semester(semester, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_semester(%Semester{} = semester, attrs) do
    semester
    |> Semester.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a semester.

  ## Examples

      iex> delete_semester(semester)
      {:ok, %Semester{}}

      iex> delete_semester(semester)
      {:error, %Ecto.Changeset{}}

  """
  def delete_semester(%Semester{} = semester) do
    Repo.delete(semester)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking semester changes.

  ## Examples

      iex> change_semester(semester)
      %Ecto.Changeset{data: %Semester{}}

  """
  def change_semester(%Semester{} = semester, attrs \\ %{}) do
    Semester.changeset(semester, attrs)
  end

  alias Attendance.Catalog.Class

  @doc """
  Returns the list of classes.

  ## Examples

      iex> list_classes()
      [%Class{}, ...]

  """
  def list_classes(%{"program_id" => program_id, "session_id" => _session_id} = _params) do
    query = from c in Class, where: c.program_id == ^program_id
    Repo.all(query)
  end

  @doc """
  Gets a single class.

  Raises `Ecto.NoResultsError` if the Class does not exist.

  ## Examples

      iex> get_class!(123)
      %Class{}

      iex> get_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_class!(id), do: Repo.get!(Class, id)

  @doc """
  Creates a class.

  ## Examples

      iex> create_class(%{field: value})
      {:ok, %Class{}}

      iex> create_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_class(admin, session, program, attrs \\ %{}) do
    %Class{}
    |> Class.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Ecto.Changeset.put_assoc(:session, session)
    |> Ecto.Changeset.put_assoc(:program, program)
    |> Repo.insert()
  end

  @doc """
  Updates a class.

  ## Examples

      iex> update_class(class, %{field: new_value})
      {:ok, %Class{}}

      iex> update_class(class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_class(%Class{} = class, attrs) do
    class
    |> Class.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a class.

  ## Examples

      iex> delete_class(class)
      {:ok, %Class{}}

      iex> delete_class(class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking class changes.

  ## Examples

      iex> change_class(class)
      %Ecto.Changeset{data: %Class{}}

  """
  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end

  alias Attendance.Catalog.Course

  @doc """
  Returns the list of course.

  ## Examples

      iex> list_course()
      [%Courses{}, ...]

  """
  def list_course(%{"semester_id" => semester_id} = _params) do
    query = from c in Course, where: c.semester_id == ^semester_id
    Repo.all(query)
  end

  @doc """
  Gets a single courses.

  Raises `Ecto.NoResultsError` if the Courses does not exist.

  ## Examples

      iex> get_courses!(123)
      %Courses{}

      iex> get_courses!(456)
      ** (Ecto.NoResultsError)

  """
  def get_courses!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a courses.

  ## Examples

      iex> create_courses(%{field: value})
      {:ok, %Courses{}}

      iex> create_courses(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_courses(admin, session, program, class, semester, attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Ecto.Changeset.put_assoc(:session, session)
    |> Ecto.Changeset.put_assoc(:program, program)
    |> Ecto.Changeset.put_assoc(:class, class)
    |> Ecto.Changeset.put_assoc(:semester, semester)
    |> Repo.insert()
  end

  @doc """
  Updates a courses.

  ## Examples

      iex> update_courses(courses, %{field: new_value})
      {:ok, %Courses{}}

      iex> update_courses(courses, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_courses(%Course{} = courses, attrs) do
    courses
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a courses.

  ## Examples

      iex> delete_courses(courses)
      {:ok, %Courses{}}

      iex> delete_courses(courses)
      {:error, %Ecto.Changeset{}}

  """
  def delete_courses(%Course{} = courses) do
    Repo.delete(courses)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking courses changes.

  ## Examples

      iex> change_courses(courses)
      %Ecto.Changeset{data: %Courses{}}

  """
  def change_courses(%Course{} = courses, attrs \\ %{}) do
    Course.changeset(courses, attrs)
  end
end
