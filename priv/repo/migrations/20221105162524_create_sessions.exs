defmodule Attendance.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :name, :string
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      add :disabled, :boolean, default: false, null: false
      add :admin_id, references(:admins, on_delete: :nothing)

      timestamps()
    end

    create index(:sessions, [:admin_id])
  end
end
