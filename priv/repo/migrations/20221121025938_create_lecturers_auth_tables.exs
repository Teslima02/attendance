defmodule Attendance.Repo.Migrations.CreateLecturersAuthTables do
  use Ecto.Migration


  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:lecturers) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :first_name, :string, null: false
      add :middle_name, :string, null: true
      add :last_name, :string, null: false
      add :disabled, :boolean, default: false
      add :matric_number, :string, null: false
      add :admin_id, references(:admins, on_delete: :nothing)
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create index(:lecturers, [:admin_id])
    create unique_index(:lecturers, [:email])
    create unique_index(:lecturers, [:matric_number])

    create table(:lecturers_tokens) do
      add :lecturer_id, references(:lecturers, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:lecturers_tokens, [:lecturer_id])
    create unique_index(:lecturers_tokens, [:context, :token])
  end
end
