defmodule Attendance.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :description, :string
      add :class_id, references(:classes, on_delete: :delete_all)
      add :course_id, references(:courses, on_delete: :delete_all)
      add :lecturer_id, references(:lecturers, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:notifications, [:class_id])
    create index(:notifications, [:course_id])
    create index(:notifications, [:lecturer_id])
  end
end
