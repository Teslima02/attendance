defmodule Attendance.Repo.Migrations.AddLecturerToCourse do
  use Ecto.Migration

  def change do
    alter table("lecturers") do
      add :courses_id, references(:courses, on_delete: :nothing)
    end

    create index(:lecturers, [:courses_id])


    alter table("courses") do
      add :lecturer_id, references(:lecturers, on_delete: :nothing)
    end

    create index(:courses, [:lecturer_id])
  end
end
