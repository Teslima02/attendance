defmodule Attendance.Repo.Migrations.AddSessionIdToProgram do
  use Ecto.Migration

  def change do
    alter table(:programs) do
      add :session_id, references(:sessions, on_delete: :nothing)
    end

    create index(:programs, [:session_id])
  end
end
