defmodule Attendance.Timetables.Timetable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timetables" do
    field :disabled, :boolean, default: false
    field :end_time, :time
    field :start_time, :time
    belongs_to :days_of_week, Attendance.Catalog.Days_of_week
    belongs_to :course, Attendance.Catalog.Course
    belongs_to :semester, Attendance.Catalog.Semester
    belongs_to :admin, Attendance.Accounts.Admin

    timestamps()
  end

  @doc false
  def changeset(timetable, attrs) do
    timetable
    |> cast(attrs, [:disabled, :start_time, :end_time])
    |> validate_required([:start_time, :end_time])
  end
end
