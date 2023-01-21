defmodule Attendance.Lecturer_attendances do
  @moduledoc """
  The Lecturer_attendances context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Lecturer_attendances.Lecturer_attendance

  import Saas.Helpers, only: [sort: 1, paginate: 4, stringify_map_key: 1]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  def paginate_attendance(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:attendances),
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
    Lecturer_attendance
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> preload([:lecturer, :course, :semester, :class])
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:attendances) do
    defconfig do
      text(:lecturer_id)
      text(:course_id)
      text(:semester_id)
      text(:class_id)
      boolean(:active)
    end
  end

  @doc """
  Returns the list of lecturer_attendances.

  ## Examples

      iex> list_lecturer_attendances()
      [%Lecturer_attendance{}, ...]

  """
  def list_lecturer_attendances do
    Repo.all(Lecturer_attendance)
  end

  @doc """
  Gets a single lecturer_attendance.

  Raises `Ecto.NoResultsError` if the Lecturer attendance does not exist.

  ## Examples

      iex> get_lecturer_attendance!(123)
      %Lecturer_attendance{}

      iex> get_lecturer_attendance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lecturer_attendance!(id), do: Repo.get!(Lecturer_attendance, id)

  @doc """
  Creates a lecturer_attendance.

  ## Examples

      iex> create_lecturer_attendance(%{field: value})
      {:ok, %Lecturer_attendance{}}

      iex> create_lecturer_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lecturer_attendance(semester, class, program, course, lecturer, attrs \\ %{}) do
    %Lecturer_attendance{}
    |> Lecturer_attendance.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:semester, semester)
    |> Ecto.Changeset.put_assoc(:class, class)
    |> Ecto.Changeset.put_assoc(:program, program)
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Ecto.Changeset.put_assoc(:lecturer, lecturer)
    |> Repo.insert()
  end

  @doc """
  Updates a lecturer_attendance.

  ## Examples

      iex> update_lecturer_attendance(lecturer_attendance, %{field: new_value})
      {:ok, %Lecturer_attendance{}}

      iex> update_lecturer_attendance(lecturer_attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lecturer_attendance(%Lecturer_attendance{} = lecturer_attendance, attrs) do
    lecturer_attendance
    |> Lecturer_attendance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lecturer_attendance.

  ## Examples

      iex> delete_lecturer_attendance(lecturer_attendance)
      {:ok, %Lecturer_attendance{}}

      iex> delete_lecturer_attendance(lecturer_attendance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lecturer_attendance(%Lecturer_attendance{} = lecturer_attendance) do
    Repo.delete(lecturer_attendance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lecturer_attendance changes.

  ## Examples

      iex> change_lecturer_attendance(lecturer_attendance)
      %Ecto.Changeset{data: %Lecturer_attendance{}}

  """
  def change_lecturer_attendance(%Lecturer_attendance{} = lecturer_attendance, attrs \\ %{}) do
    Lecturer_attendance.changeset(lecturer_attendance, attrs)
  end

  # This will return data if the end_time has not reach and turn active to false if the time has reach
  def check_and_update_if_attendance_time_expire!(attendance_id) do
    attendee = get_lecturer_attendance!(attendance_id)

    if attendee.active == true and
         attendee.end_date > DateTime.truncate(DateTime.utc_now(), :second) do
      attendee
    else
      attendee
      |> Lecturer_attendance.changeset(%{active: false})
      |> Repo.update()

      get_lecturer_attendance!(attendee.id)
    end
  end
end
