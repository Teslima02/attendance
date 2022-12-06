defmodule Attendance.Repo.Migrations.LecturerCourse do
  use Ecto.Migration

  def change do
    create table(:lecturer_course, primary_key: false) do
      add(:lecturer_id, references(:lecturers, on_delete: :delete_all), primary_key: true)
      add(:course_id, references(:courses, on_delete: :delete_all), primary_key: true)

      timestamps()
    end

    create index(:lecturer_course, [:lecturer_id])
    create index(:lecturer_course, [:course_id])

    create unique_index(:lecturer_course, [:lecturer_id, :course_id])
  end
end
