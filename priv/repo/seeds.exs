# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Attendance.Repo.insert!(%Attendance.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Attendance.Catalog

defmodule AttendanceSeed do
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_user_id, do: "user#{System.unique_integer()}"
  def unique_password, do: "Password@123"

  def multiply_seeder() do
    create_period()
    create_days_of_week()
  end

  def create_period() do
    Enum.each(1..12, fn row ->
      {:ok, start_time} = Time.new(7+row, 0, 0, 0)
      {:ok, end_time} = Time.new(8+row, 0, 0, 0)

      periods = %{
        start_time: start_time,
        end_time: end_time,
      }
      Catalog.create_period(periods)
    end)
  end

  def create_days_of_week() do
    days = [
      %{
        name: "monday",
      },
      %{
        name: "tuesday",
      },
      %{
        name: "wednesday",
      },
      %{
        name: "thursday",
      },
      %{
        name: "friday",
      },
    ]
    Enum.each(days, fn row ->
      Catalog.create_days_of_week(row)
    end)
  end
end

AttendanceSeed.multiply_seeder()
