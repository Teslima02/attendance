defmodule Attendance.Repo.Migrations.ChangeDisabledInSessionToTrue do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      modify :disabled, :boolean, default: true, null: false
    end
  end
end
