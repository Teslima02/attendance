defmodule Attendance.TimetablesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Timetables` context.
  """

  @doc """
  Generate a timetable.
  """
  def timetable_fixture(attrs \\ %{}) do
    {:ok, timetable} =
      attrs
      |> Enum.into(%{
        disabled: true,
        end_time: ~T[14:00:00],
        start_time: ~T[14:00:00]
      })
      |> Attendance.Timetables.create_timetable()

    timetable
  end
end
