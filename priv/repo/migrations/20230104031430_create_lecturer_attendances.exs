defmodule Attendance.Repo.Migrations.CreateLecturerAttendances do
  use Ecto.Migration

  def change do
    create table(:lecturer_attendances) do
      add :active, :boolean, default: false, null: true
      add :start_date, :naive_datetime
      add :end_date, :naive_datetime
      add :semester_id, references(:semesters, on_delete: :nothing)
      add :class_id, references(:classes, on_delete: :nothing)
      add :program_id, references(:programs, on_delete: :nothing)
      add :lecturer_id, references(:lecturers, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps()
    end

    create index(:lecturer_attendances, [:semester_id])
    create index(:lecturer_attendances, [:class_id])
    create index(:lecturer_attendances, [:program_id])
    create index(:lecturer_attendances, [:lecturer_id])
    create index(:lecturer_attendances, [:course_id])
  end
end
