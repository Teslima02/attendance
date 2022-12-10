defmodule Attendance.Repo.Migrations.CreateLecturerHalls do
  use Ecto.Migration

  def change do
    create table(:lecturer_halls) do
      add :hall_number, :string
      add :building_name, :string
      add :disabled, :boolean, default: false, null: false

      timestamps()
    end
  end
end
