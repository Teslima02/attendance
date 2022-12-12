defmodule Attendance.Timetables do
  @moduledoc """
  The Timetables context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Timetables.Timetable

  @doc """
  Returns the list of timetables.

  ## Examples

      iex> list_timetables()
      [%Timetable{}, ...]

  """
  def list_timetables(%{"semester_id" => semester_id} = _params) do
    query = from(t in Timetable, where: t.semester_id == ^semester_id)
    Repo.all(query)
    |> Repo.preload([:start_time, :end_time, :course, :lecture_hall, :semester, :admin, :days_of_week])
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
  def create_timetable(admin, course, day, lecture_hall, start_time, end_time, semester, attrs \\ %{}) do
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
  def update_timetable(%Timetable{} = timetable, course, day, lecture_hall, start_time, end_time, attrs) do
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
end
