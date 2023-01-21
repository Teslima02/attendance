defmodule Attendance.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Attendance.Repo

  alias Attendance.Notifications.Notification

  import Saas.Helpers, only: [sort: 1, paginate: 4, stringify_map_key: 1]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  def paginate_notification(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
            filter_config(:notifications),
             stringify_map_key(params[:notification]) || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_notification(filter, params) do
      {:ok,
       %{
        notifications: page.entries,
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

  defp do_paginate_notification(filter, params) do
    Notification
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> preload([:class, :course, :lecturer])
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:notifications) do
    defconfig do
      text(:description)
      text(:course_id)
      text(:class_id)
      boolean(:lecturer_id)
    end
  end

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id),
    do: Repo.get!(Notification, id) |> Repo.preload([:course, :class, :lecturer])

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(course, class, lecturer, attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Ecto.Changeset.put_assoc(:class, class)
    |> Ecto.Changeset.put_assoc(:lecturer, lecturer)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
