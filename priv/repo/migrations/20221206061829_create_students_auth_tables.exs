defmodule Attendance.Repo.Migrations.CreateStudentsAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:students) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :first_name, :string, null: false
      add :middle_name, :string, null: true
      add :last_name, :string, null: false
      add :disabled, :boolean, default: false
      add :matric_number, :string, null: false
      add :admin_id, references(:admins, on_delete: :delete_all)
      add :class_id, references(:classes, on_delete: :delete_all)
      timestamps()
    end

    create unique_index(:students, [:email, :matric_number])
    create index(:students, [:admin_id])
    create index(:students, [:class_id])

    create table(:students_tokens) do
      add :student_id, references(:students, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:students_tokens, [:student_id])
    create unique_index(:students_tokens, [:context, :token])
  end
end
