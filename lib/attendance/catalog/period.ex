defmodule Attendance.Catalog.Period do
  use Ecto.Schema
  import Ecto.Changeset

  schema "periods" do
    field :disabled, :boolean, default: false
    field :end_time, :time
    field :start_time, :time
    belongs_to :admin, Attendance.Accounts.Admin

    timestamps()
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [:start_time, :end_time, :disabled])
    |> validate_required([:start_time, :end_time])
  end
end
