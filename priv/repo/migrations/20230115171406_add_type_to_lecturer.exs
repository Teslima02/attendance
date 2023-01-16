defmodule Attendance.Repo.Migrations.AddTypeToLecturer do
  use Ecto.Migration

  def change do
    alter table(:lecturers) do
      add :account_type, :string, default: "lecturer", null: false
    end
  end
end
