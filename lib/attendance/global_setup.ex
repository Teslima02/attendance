defmodule Attendance.GlobalSetup do
  alias Attendance.Catalog
  alias Attendance.Timetables

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_user_id, do: "user#{System.unique_integer()}"
  def unique_password, do: "Password@123"

  def multiply_seeder() do
    create_period()
    create_days_of_week()
  end

  def create_period() do

    # Delete all timetable record first
    Timetables.delete_all_timetable()

    # Delete all period record first
    Catalog.delete_all_period()

    # insert the seed files
    Enum.each(1..22, fn row ->
      {:ok, start_time} = Time.new(0 + row, 0, 0, 0)
      {:ok, end_time} = Time.new(1 + row, 0, 0, 0)

      periods = %{
        start_time: start_time,
        end_time: end_time
      }

      Catalog.create_period(periods)
    end)
  end

  def create_days_of_week() do
    # Delete all days_of_the_week record first
    Catalog.delete_all_days_of_week()

    days = [
      %{
        name: "monday"
      },
      %{
        name: "tuesday"
      },
      %{
        name: "wednesday"
      },
      %{
        name: "thursday"
      },
      %{
        name: "friday"
      },
      %{
        name: "saturday"
      },
      %{
        name: "sunday"
      }
    ]

    Enum.each(days, fn row ->
      Catalog.create_days_of_week(row)
    end)
  end
end
