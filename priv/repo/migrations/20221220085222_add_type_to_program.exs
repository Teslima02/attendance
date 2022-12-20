defmodule Attendance.Repo.Migrations.AddTypeToProgram do
  use Ecto.Migration

  def change do
    alter table(:programs) do
      add :program_type, :string
    end
  end
end
