defmodule Attendance.Repo.Migrations.AddTypeToStudent do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :account_type, :string, default: "student", null: false
    end
  end
end
