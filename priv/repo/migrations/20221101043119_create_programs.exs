defmodule Attendance.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string
      add :description, :string
      add :disabled, :boolean, default: false, null: false
      add :admin_id, references(:admins, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:programs, [:name])
    create index(:programs, [:admin_id])
  end
end
