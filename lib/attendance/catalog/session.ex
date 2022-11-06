defmodule Attendance.Catalog.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :description, :string
    field :disabled, :boolean, default: false
    field :end_date, :date
    field :name, :string
    field :start_date, :date
    belongs_to :admin, Attendance.Accounts.Admin

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:name, :description, :start_date, :end_date, :disabled])
    |> validate_required([:name, :description, :start_date, :end_date])
  end
end
