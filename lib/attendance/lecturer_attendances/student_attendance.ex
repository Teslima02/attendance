defmodule Attendance.Lecturer_attendances.Student_attendance do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  schema "student_attendances" do
    field :status, :boolean, default: false
    field :attendance_time, :utc_datetime
    belongs_to :student, Attendance.Students.Student
    belongs_to :course, Attendance.Catalog.Course
    belongs_to :lecturer_attendance, Attendance.Lecturer_attendances.Lecturer_attendance

    timestamps()
  end

  @doc false
  def changeset(lecturer_attendance, attrs) do
    lecturer_attendance
    |> cast(attrs, [:status, :attendance_time])
    |> validate_required([:status, :attendance_time])
  end
end
