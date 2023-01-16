defmodule Attendance.Repo.Migrations.AddTypeToAdmin do
  use Ecto.Migration

  def change do
    alter table(:admins) do
      add :account_type, :string, default: "admin", null: false
    end
  end
end
