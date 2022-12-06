defmodule Attendance.Catalog.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :code, :string
    field :description, :string
    field :name, :string
    belongs_to :admin, Attendance.Accounts.Admin
    belongs_to :session, Attendance.Catalog.Session
    belongs_to :program, Attendance.Catalog.Program
    belongs_to :class, Attendance.Catalog.Class
    belongs_to :semester, Attendance.Catalog.Semester
    many_to_many :lecturer, Attendance.Lecturers.Lecturer, join_through: Attendance.Catalog.LecturerCourses, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(courses, attrs) do
    courses
    |> cast(attrs, [:name, :description, :code])
    # |> validate_required([:name, :code])
  end
end
