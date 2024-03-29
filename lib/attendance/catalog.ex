defmodule Attendance.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Catalog.Class
  alias Attendance.Repo

  import Saas.Helpers, only: [sort: 1, paginate: 4, stringify_map_key: 1]
  import Filtrex.Type.Config

  alias Attendance.Catalog.Program

  @pagination [page_size: 15]
  @pagination_distance 5

  def paginate_programs(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:programs),
             stringify_map_key(params[:program]) || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_programs(filter, params) do
      {:ok,
       %{
         programs: page.entries,
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

  defp do_paginate_programs(filter, params) do
    Program
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:programs) do
    defconfig do
      text(:name)
      text(:program_type)
      text(:session_id)
      boolean(:disabled)
    end
  end

  def paginate_classes(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config_class(:classes),
             stringify_map_key(params[:class]) || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_class(filter, params) do
      {:ok,
       %{
         classes: page.entries,
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

  defp do_paginate_class(filter, params) do
    Class
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config_class(:classes) do
    defconfig do
      text(:name)
      text(:session_id)
      text(:program_id)
      boolean(:disabled)
    end
  end

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

  def get_current_session! do
    query = from s in Session, where: s.disabled == false
    Repo.one(query)
  end

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

  def get_current_semester!(input_params) do
    query =
      from s in Semester,
        join: p in Program, on: [id: s.program_id, session_id: ^get_current_session!().id, program_type: ^input_params.program_type],
        where: [disabled: false]

    Repo.one(query)
  end

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
  def change_courses(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  alias Attendance.Catalog.Period

  @doc """
  Returns the list of periods.

  ## Examples

      iex> list_periods()
      [%Period{}, ...]

  """
  def list_periods do
    Repo.all(Period)
  end

  @doc """
  Gets a single period.

  Raises `Ecto.NoResultsError` if the Period does not exist.

  ## Examples

      iex> get_period!(123)
      %Period{}

      iex> get_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_period!(id), do: Repo.get!(Period, id)

  @doc """
  Creates a period.

  ## Examples

      iex> create_period(%{field: value})
      {:ok, %Period{}}

      iex> create_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_period(attrs \\ %{}) do
    %Period{}
    |> Period.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a period.

  ## Examples

      iex> update_period(period, %{field: new_value})
      {:ok, %Period{}}

      iex> update_period(period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_period(%Period{} = period, attrs) do
    period
    |> Period.changeset(attrs)
    |> Repo.update()
  end

  def delete_all_period() do
    Repo.delete_all(Period)
  end

  @doc """
  Deletes a period.

  ## Examples

      iex> delete_period(period)
      {:ok, %Period{}}

      iex> delete_period(period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_period(%Period{} = period) do
    Repo.delete(period)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking period changes.

  ## Examples

      iex> change_period(period)
      %Ecto.Changeset{data: %Period{}}

  """
  def change_period(%Period{} = period, attrs \\ %{}) do
    Period.changeset(period, attrs)
  end

  alias Attendance.Catalog.Days_of_week

  @doc """
  Returns the list of days_of_weeks.

  ## Examples

      iex> list_days_of_weeks()
      [%Days_of_week{}, ...]

  """
  def list_days_of_weeks do
    Repo.all(Days_of_week)
  end

  @doc """
  Gets a single days_of_week.

  Raises `Ecto.NoResultsError` if the Days of week does not exist.

  ## Examples

      iex> get_days_of_week!(123)
      %Days_of_week{}

      iex> get_days_of_week!(456)
      ** (Ecto.NoResultsError)

  """
  def get_days_of_week!(id), do: Repo.get!(Days_of_week, id)

  @doc """
  Creates a days_of_week.

  ## Examples

      iex> create_days_of_week(%{field: value})
      {:ok, %Days_of_week{}}

      iex> create_days_of_week(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_days_of_week(attrs \\ %{}) do
    %Days_of_week{}
    |> Days_of_week.changeset(attrs)
    |> Repo.insert()
  end

  def delete_all_days_of_week() do
    Repo.delete_all(Days_of_week)
  end

  @doc """
  Updates a days_of_week.

  ## Examples

      iex> update_days_of_week(days_of_week, %{field: new_value})
      {:ok, %Days_of_week{}}

      iex> update_days_of_week(days_of_week, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_days_of_week(%Days_of_week{} = days_of_week, attrs) do
    days_of_week
    |> Days_of_week.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a days_of_week.

  ## Examples

      iex> delete_days_of_week(days_of_week)
      {:ok, %Days_of_week{}}

      iex> delete_days_of_week(days_of_week)
      {:error, %Ecto.Changeset{}}

  """
  def delete_days_of_week(%Days_of_week{} = days_of_week) do
    Repo.delete(days_of_week)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking days_of_week changes.

  ## Examples

      iex> change_days_of_week(days_of_week)
      %Ecto.Changeset{data: %Days_of_week{}}

  """
  def change_days_of_week(%Days_of_week{} = days_of_week, attrs \\ %{}) do
    Days_of_week.changeset(days_of_week, attrs)
  end
end
