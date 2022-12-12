defmodule Attendance.Lecturer_hallsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Lecturer_halls` context.
  """

  @doc """
  Generate a lecturer_hall.
  """
  def lecturer_hall_fixture(attrs \\ %{}) do
    {:ok, lecturer_hall} =
      attrs
      |> Enum.into(%{
        building_name: "some building_name",
        disabled: true,
        hall_number: "some hall_number"
      })
      |> Attendance.Lecturer_halls.create_lecturer_hall()

    lecturer_hall
  end
end
