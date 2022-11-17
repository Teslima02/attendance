defmodule Attendance.Repo.Migrations.CreateCourse do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :description, :string
      add :code, :string
      add :session_id, references(:sessions, on_delete: :nothing)
      add :semester_id, references(:semesters, on_delete: :nothing)
      add :program_id, references(:programs, on_delete: :nothing)
      add :class_id, references(:classes, on_delete: :nothing)
      add :admin_id, references(:admins, on_delete: :nothing)

      timestamps()
    end

    create index(:courses, [:session_id])
    create index(:courses, [:semester_id])
    create index(:courses, [:program_id])
    create index(:courses, [:class_id])
    create index(:courses, [:admin_id])
  end
end
