defmodule Attendance.Repo.Migrations.AddProgramToStudent do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :program_id, references(:programs, on_delete: :delete_all)
    end

    create index(:students, [:program_id])
  end
end
