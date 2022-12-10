defmodule Attendance.Repo.Migrations.CreateTimetables do
  use Ecto.Migration

  def change do
    create table(:timetables) do
      add :disabled, :boolean, default: false, null: false
      add :start_time, :time
      add :end_time, :time
      add :days_of_week_id, references(:days_of_weeks, on_delete: :delete_all)
      add :course_id, references(:courses, on_delete: :delete_all)
      add :semester_id, references(:semesters, on_delete: :delete_all)
      add :admin_id, references(:admins, on_delete: :delete_all)

      timestamps()
    end

    create index(:timetables, [:days_of_week_id])
    create index(:timetables, [:course_id])
    create index(:timetables, [:semester_id])
    create index(:timetables, [:admin_id])
  end
end
