defmodule Attendance.Catalog.Days_of_week do
  use Ecto.Schema
  import Ecto.Changeset

  schema "days_of_weeks" do
    field :disabled, :boolean, default: false
    field :name, :string
    belongs_to :admin, Attendance.Accounts.Admin

    timestamps()
  end

  @doc false
  def changeset(days_of_week, attrs) do
    days_of_week
    |> cast(attrs, [:name, :disabled])
    |> validate_required([:name])
  end
end
