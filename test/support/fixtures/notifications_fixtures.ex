defmodule Attendance.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Enum.into(%{
        description: "some description"
      })
      |> Attendance.Notifications.create_notification()

    notification
  end
end
