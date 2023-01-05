defmodule Attendance.Lecturer_attendancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Lecturer_attendances` context.
  """

  @doc """
  Generate a lecturer_attendance.
  """
  def lecturer_attendance_fixture(attrs \\ %{}) do
    {:ok, lecturer_attendance} =
      attrs
      |> Enum.into(%{
        end_date: ~N[2023-01-03 03:14:00],
        start_date: ~N[2023-01-03 03:14:00],
        status: true
      })
      |> Attendance.Lecturer_attendances.create_lecturer_attendance()

    lecturer_attendance
  end
end
