defmodule Attendance.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Attendance.Catalog` context.
  """

  alias Attendance.AccountsFixtures

  @doc """
  Generate a unique program name.
  """
  def unique_program_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a program.
  """
  def program_fixture(attrs \\ %{}) do
    
      attrs =
      Enum.into(attrs, %{
        description: "some description",
        disabled: true,
        name: unique_program_name()
      })

      admin = AccountsFixtures.admin_fixture()
      {:ok, program} = Attendance.Catalog.create_program(admin, attrs)

    program
  end

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(%{
        description: "some description",
        disabled: true,
        end_date: ~N[2022-11-04 16:25:00],
        name: "some name",
        start_date: ~N[2022-11-04 16:25:00]
      })
      |> Attendance.Catalog.create_session()

    session
  end

  @doc """
  Generate a semester.
  """
  def semester_fixture(attrs \\ %{}) do
    {:ok, semester} =
      attrs
      |> Enum.into(%{
        disabled: true,
        end_date: ~D[2022-11-07],
        name: "some name",
        start_date: ~D[2022-11-07]
      })
      |> Attendance.Catalog.create_semester()

    semester
  end

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    {:ok, class} =
      attrs
      |> Enum.into(%{
        disabled: true,
        name: "some name"
      })
      |> Attendance.Catalog.create_class()

    class
  end

  @doc """
  Generate a period.
  """
  def period_fixture(attrs \\ %{}) do
    {:ok, period} =
      attrs
      |> Enum.into(%{
        disabled: true,
        end_time: ~T[14:00:00],
        start_time: ~T[14:00:00]
      })
      |> Attendance.Catalog.create_period()

    period
  end

  @doc """
  Generate a days_of_week.
  """
  def days_of_week_fixture(attrs \\ %{}) do
    {:ok, days_of_week} =
      attrs
      |> Enum.into(%{
        disabled: true,
        name: "some name"
      })
      |> Attendance.Catalog.create_days_of_week()

    days_of_week
  end
end
