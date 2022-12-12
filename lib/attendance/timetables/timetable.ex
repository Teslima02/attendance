defmodule Attendance.Timetables.Timetable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timetables" do
    field :disabled, :boolean, default: false
    belongs_to :start_time, Attendance.Catalog.Period
    belongs_to :end_time, Attendance.Catalog.Period
    belongs_to :days_of_week, Attendance.Catalog.Days_of_week
    belongs_to :course, Attendance.Catalog.Course
    belongs_to :lecture_hall, Attendance.Lecturer_halls.Lecturer_hall
    belongs_to :semester, Attendance.Catalog.Semester
    belongs_to :admin, Attendance.Accounts.Admin

    timestamps()
  end

  @doc false
  def changeset(timetable, attrs) do
    timetable
    |> cast(attrs, [:disabled])
    |> validate_required([])
  end
end
