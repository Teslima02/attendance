defmodule Attendance.Catalog.Semester do
  use Ecto.Schema
  import Ecto.Changeset

  schema "semesters" do
    field :disabled, :boolean, default: false
    field :end_date, :date
    field :name, :string
    field :start_date, :date
    belongs_to :admin, Attendance.Accounts.Admin
    belongs_to :session, Attendance.Catalog.Session
    belongs_to :program, Attendance.Catalog.Program
    belongs_to :class, Attendance.Catalog.Class

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [:name, :start_date, :end_date, :disabled])
    |> validate_required([:name, :start_date, :end_date])
  end
end
