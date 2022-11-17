defmodule Attendance.CategoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Category` context.
  """

  @doc """
  Generate a courses.
  """
  def courses_fixture(attrs \\ %{}) do
    {:ok, courses} =
      attrs
      |> Enum.into(%{
        code: "some code",
        description: "some description",
        name: "some name"
      })
      |> Attendance.Category.create_courses()

    courses
  end
end
