defmodule Attendance.Lecturer_attendances.Student_attendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "student_attendances" do
    field :status, :boolean, default: false
    belongs_to :student, Attendance.Students.Student
    belongs_to :course, Attendance.Catalog.Course
    belongs_to :lecturer_attendance_id, Attendance.Lecturer_attendances.Lecturer_attendance

    timestamps()
  end

  @doc false
  def changeset(lecturer_attendance, attrs) do
    lecturer_attendance
    |> cast(attrs, [:status, :start_date, :end_date])
    |> validate_required([:status, :start_date, :end_date])
  end
end
