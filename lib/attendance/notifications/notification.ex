defmodule Attendance.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  schema "notifications" do
    field :description, :string
    belongs_to :class, Attendance.Catalog.Class
    belongs_to :course, Attendance.Catalog.Course
    belongs_to :lecturer, Attendance.Lecturers.Lecturer

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
