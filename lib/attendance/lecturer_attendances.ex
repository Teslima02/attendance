defmodule Attendance.Lecturer_attendances do
  @moduledoc """
  The Lecturer_attendances context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Lecturer_attendances.Lecturer_attendance

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
end
