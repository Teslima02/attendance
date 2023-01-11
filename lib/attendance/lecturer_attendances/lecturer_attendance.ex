defmodule Attendance.Lecturer_attendances.Lecturer_attendance do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  schema "lecturer_attendances" do
    field :end_date, :utc_datetime
    field :start_date, :utc_datetime
    field :active, :boolean, default: true
    belongs_to :semester, Attendance.Catalog.Semester
    belongs_to :class, Attendance.Catalog.Class
    belongs_to :program, Attendance.Catalog.Program
    belongs_to :course, Attendance.Catalog.Course
    belongs_to :lecturer, Attendance.Lecturers.Lecturer

    timestamps()
  end

  @doc false
  def changeset(lecturer_attendance, attrs) do
    lecturer_attendance
    |> cast(attrs, [:active, :start_date, :end_date])
    |> validate_required([:active, :start_date, :end_date])
  end
end
