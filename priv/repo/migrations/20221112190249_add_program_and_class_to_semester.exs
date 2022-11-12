defmodule Attendance.Repo.Migrations.AddProgramAndClassToSemester do
  use Ecto.Migration

  def change do
    alter table(:semesters) do
      add :program_id, references(:programs, on_delete: :nothing)
      add :class_id, references(:classes, on_delete: :nothing)
    end

    create index(:semesters, [:program_id])
    create index(:semesters, [:class_id])
  end
end
