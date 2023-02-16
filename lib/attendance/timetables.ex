defmodule Attendance.Timetables do
  @moduledoc """
  The Timetables context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Timetables.Timetable
  alias Attendance.Catalog.{Period, Course, Days_of_week}
  alias Attendance.Lecturers
  alias Attendance.Students

  @doc """
  Returns the list of timetables.

  ## Examples

      iex> list_timetables()
      [%Timetable{}, ...]

  """
  def list_timetables(%{"semester_id" => semester_id} = _params) do
    query = from(t in Timetable, where: t.semester_id == ^semester_id)

    Repo.all(query)
    |> Repo.preload([
      :start_time,
      :end_time,
      :course,
      :lecture_hall,
      :semester,
      :admin,
      :days_of_week
    ])
  end

  @doc """
  Gets a single timetable.

  Raises `Ecto.NoResultsError` if the Timetable does not exist.

  ## Examples

      iex> get_timetable!(123)
      %Timetable{}

      iex> get_timetable!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timetable!(id), do: Repo.get!(Timetable, id)

  @doc """
  Creates a timetable.

  ## Examples

      iex> create_timetable(%{field: value})
      {:ok, %Timetable{}}

      iex> create_timetable(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timetable(
        admin,
        course,
        day,
        lecture_hall,
        start_time,
        end_time,
        semester,
        attrs \\ %{}
      ) do
    %Timetable{}
    |> Timetable.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:admin, admin)
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Ecto.Changeset.put_assoc(:days_of_week, day)
    |> Ecto.Changeset.put_assoc(:start_time, start_time)
    |> Ecto.Changeset.put_assoc(:end_time, end_time)
    |> Ecto.Changeset.put_assoc(:lecture_hall, lecture_hall)
    |> Ecto.Changeset.put_assoc(:semester, semester)
    |> Repo.insert()
  end

  @doc """
  Updates a timetable.

  ## Examples

      iex> update_timetable(timetable, %{field: new_value})
      {:ok, %Timetable{}}

      iex> update_timetable(timetable, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timetable(
        %Timetable{} = timetable,
        course,
        day,
        lecture_hall,
        start_time,
        end_time,
        attrs
      ) do
    timetable
    |> Timetable.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Ecto.Changeset.put_assoc(:days_of_week, day)
    |> Ecto.Changeset.put_assoc(:start_time, start_time)
    |> Ecto.Changeset.put_assoc(:end_time, end_time)
    |> Ecto.Changeset.put_assoc(:lecture_hall, lecture_hall)
    |> Repo.update()
  end

  @doc """
  Deletes a timetable.

  ## Examples

      iex> delete_timetable(timetable)
      {:ok, %Timetable{}}

      iex> delete_timetable(timetable)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timetable(%Timetable{} = timetable) do
    Repo.delete(timetable)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timetable changes.

  ## Examples

      iex> change_timetable(timetable)
      %Ecto.Changeset{data: %Timetable{}}

  """
  def change_timetable(%Timetable{} = timetable, attrs \\ %{}) do
    Timetable.changeset(timetable, attrs)
  end

  def student_current_period(current_student) do
    now = Time.utc_now()
    day_of_week = Calendar.strftime(DateTime.utc_now(), "%A") |> String.downcase()

    # get student courses and get it [ids]
    course_ids =
      Students.student_courses(current_student)
      |> Enum.map(fn x -> x.id end)

    week_day_query = Repo.one(from d in Days_of_week, where: d.name == ^day_of_week)
    # week_day_query = Repo.one(from d in Days_of_week, where: d.name == "friday")
    period_query = Repo.one(from p in Period, where: p.start_time <= ^now and p.end_time >= ^now)

    # get timetable of the courses
    if period_query != nil and week_day_query != nil do
      query =
        from t in Timetable,
          where:
            # t.start_time_id == ^period_query.id and t.days_of_week_id == ^week_day_query.id and
            t.start_time_id <= ^period_query.id and t.end_time_id >= ^period_query.id and t.days_of_week_id == ^week_day_query.id and
              t.course_id in ^course_ids

      {:ok, Repo.one(query)
      |> Repo.preload([
        :start_time,
        :end_time,
        :course,
        :lecture_hall,
        :semester,
        :days_of_week
      ])
      }

      # Repo.all(query)
    else
      {:error, "No current period or today is weekend"}
    end
  end

  def lecturer_current_period(current_lecturer) do
    now = Time.utc_now()
    day_of_week = Calendar.strftime(DateTime.utc_now(), "%A") |> String.downcase()

    # get lecturer courses and get it [ids]
    course_ids =
      Lecturers.lecturer_courses(current_lecturer)
      |> Enum.map(fn x -> x.id end)

    week_day_query = Repo.one(from d in Days_of_week, where: d.name == ^day_of_week)
    period_query = Repo.one(from p in Period, where: p.start_time <= ^now and p.end_time >= ^now)

    # get timetable of the courses
    if period_query != nil do
      query =
        from t in Timetable,
          where:
            # t.start_time_id == ^period_query.id and t.days_of_week_id == ^week_day_query.id and
            t.start_time_id <= ^period_query.id and t.end_time_id >= ^period_query.id and t.days_of_week_id == ^week_day_query.id and
              t.course_id in ^course_ids

      Repo.one(query)
      |> Repo.preload([
        :start_time,
        :end_time,
        :course,
        :lecture_hall,
        :semester,
        :days_of_week
      ])

      # Repo.all(query)
    else
      {:error, "No current period"}
    end
  end

  def lecturer_daily_period(current_lecturer) do
    now = Time.utc_now()
    day_of_week = Calendar.strftime(DateTime.utc_now(), "%A") |> String.downcase()

    # get lecturer courses and get it [ids]
    course_ids =
      Lecturers.lecturer_courses(current_lecturer)
      |> Enum.map(fn x -> x.id end)

    week_day_query = Repo.one(from d in Days_of_week, where: d.name == ^day_of_week)
    period_query = Repo.one(from p in Period, where: p.start_time <= ^now and p.end_time >= ^now)

    # get timetable of the courses
    if period_query != nil do
      query =
        from t in Timetable,
          where: t.days_of_week_id == ^week_day_query.id and t.course_id in ^course_ids

      Repo.all(query)
      |> Repo.preload([
        :start_time,
        :end_time,
        :course,
        :lecture_hall,
        :semester,
        :days_of_week
      ])
    else
      {:error, "No current period"}
    end
  end

  def lecturer_next_period(current_lecturer) do
    next_now = Time.utc_now() |> Time.add(2, :hour)

    day_of_week = Calendar.strftime(DateTime.utc_now(), "%A") |> String.downcase()

    # get lecturer courses and get it [ids]
    course_ids =
      Lecturers.lecturer_courses(current_lecturer)
      |> Enum.map(fn x -> x.id end)

    week_day_query = Repo.one(from d in Days_of_week, where: d.name == ^day_of_week)
    # TODO:: check this later rework timetable for proper timetable with period
    period_query =
      Repo.one(from p in Period, where: p.start_time <= ^next_now and ^next_now <= p.end_time)

    # get timetable of the courses
    if period_query != nil do
      query =
        from t in Timetable,
          where:
          # TODO: rework this
            t.start_time_id == ^period_query.id and t.days_of_week_id == ^week_day_query.id and
              t.course_id in ^course_ids

      Repo.one(query)
      |> Repo.preload([
        :start_time,
        :end_time,
        :course,
        :lecture_hall,
        :semester,
        :days_of_week
      ])

      # Repo.all(query) |> IO.inspect()
    else
      {:error, "No current period"}
    end
  end
end
