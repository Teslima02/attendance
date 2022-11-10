defmodule Attendance.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :disabled, :boolean, default: false, null: false
      add :session_id, references(:sessions, on_delete: :nothing)
      add :admin_id, references(:admins, on_delete: :nothing)

      timestamps()
    end

    create index(:semesters, [:session_id])
    create index(:semesters, [:admin_id])
  end
end
