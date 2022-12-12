defmodule Attendance.Lecturer_halls.Lecturer_hall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lecturer_halls" do
    field :building_name, :string
    field :disabled, :boolean, default: false
    field :hall_number, :string

    timestamps()
  end

  @doc false
  def changeset(lecturer_hall, attrs) do
    lecturer_hall
    |> cast(attrs, [:hall_number, :building_name, :disabled])
    |> validate_required([:hall_number, :building_name])
  end
end
