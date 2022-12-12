defmodule Attendance.Lecturer_halls do
  @moduledoc """
  The Lecturer_halls context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Lecturer_halls.Lecturer_hall

  @doc """
  Returns the list of lecturer_halls.

  ## Examples

      iex> list_lecturer_halls()
      [%Lecturer_hall{}, ...]

  """
  def list_lecturer_halls do
    Repo.all(Lecturer_hall)
  end

  @doc """
  Gets a single lecturer_hall.

  Raises `Ecto.NoResultsError` if the Lecturer hall does not exist.

  ## Examples

      iex> get_lecturer_hall!(123)
      %Lecturer_hall{}

      iex> get_lecturer_hall!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lecturer_hall!(id), do: Repo.get!(Lecturer_hall, id)

  @doc """
  Creates a lecturer_hall.

  ## Examples

      iex> create_lecturer_hall(%{field: value})
      {:ok, %Lecturer_hall{}}

      iex> create_lecturer_hall(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lecturer_hall(attrs \\ %{}) do
    %Lecturer_hall{}
    |> Lecturer_hall.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lecturer_hall.

  ## Examples

      iex> update_lecturer_hall(lecturer_hall, %{field: new_value})
      {:ok, %Lecturer_hall{}}

      iex> update_lecturer_hall(lecturer_hall, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lecturer_hall(%Lecturer_hall{} = lecturer_hall, attrs) do
    lecturer_hall
    |> Lecturer_hall.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lecturer_hall.

  ## Examples

      iex> delete_lecturer_hall(lecturer_hall)
      {:ok, %Lecturer_hall{}}

      iex> delete_lecturer_hall(lecturer_hall)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lecturer_hall(%Lecturer_hall{} = lecturer_hall) do
    Repo.delete(lecturer_hall)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lecturer_hall changes.

  ## Examples

      iex> change_lecturer_hall(lecturer_hall)
      %Ecto.Changeset{data: %Lecturer_hall{}}

  """
  def change_lecturer_hall(%Lecturer_hall{} = lecturer_hall, attrs \\ %{}) do
    Lecturer_hall.changeset(lecturer_hall, attrs)
  end
end
