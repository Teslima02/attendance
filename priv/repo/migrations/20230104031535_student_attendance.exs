defmodule Attendance.Repo.Migrations.StudentAttendance do
  use Ecto.Migration

  def change do
    create table(:student_attendances) do
      add :status, :boolean, default: false, null: false
      add :student_id, references(:students, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)
      add :lecturer_attendance_id, references(:lecturer_attendances, on_delete: :nothing)

      timestamps()
    end

    create index(:student_attendances, [:student_id])
    create index(:student_attendances, [:course_id])
    create index(:student_attendances, [:lecturer_attendance_id])
  end
end
