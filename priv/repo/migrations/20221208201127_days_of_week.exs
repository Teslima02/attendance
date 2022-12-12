defmodule Attendance.Repo.Migrations.DaysOfWeek do
  use Ecto.Migration

  def change do
    create table(:days_of_weeks) do
      add :name, :string
      add :disabled, :boolean, default: false, null: false
      add :admin_id, references(:admins, on_delete: :delete_all)

      timestamps()
    end

    create index(:days_of_weeks, [:admin_id])
    create unique_index(:days_of_weeks, [:name])

    create table(:periods) do
      add :start_time, :time
      add :end_time, :time
      add :disabled, :boolean, default: false, null: false
      add :admin_id, references(:admins, on_delete: :delete_all)

      timestamps()
    end

    create index(:periods, [:admin_id])
    create unique_index(:periods, [:start_time, :end_time])
  end
end
