defmodule Attendance.Catalog.LecturerCourses do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "lecturer_course" do
    belongs_to :course, Attendance.Catalog.Course, primary_key: true
    belongs_to :lecturer, Attendance.Lecturers.Lecturer, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(lecturer_course, attrs \\ %{}) do
    lecturer_course
    |> cast(attrs, [:course_id, :lecturer_id])
  end
end
