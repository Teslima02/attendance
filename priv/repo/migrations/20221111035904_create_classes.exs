defmodule Attendance.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :name, :string
      add :disabled, :boolean, default: false, null: false
      add :admin_id, references(:admins, on_delete: :nothing)
      add :session_id, references(:sessions, on_delete: :nothing)
      add :program_id, references(:programs, on_delete: :nothing)

      timestamps()
    end

    create index(:classes, [:admin_id])
    create index(:classes, [:session_id])
    create index(:classes, [:program_id])
  end
end
