defmodule Attendance.Catalog.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field :disabled, :boolean, default: false
    field :name, :string
    belongs_to :program, Attendance.Catalog.Program
    belongs_to :admin, Attendance.Accounts.Admin
    belongs_to :session, Attendance.Catalog.Session

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :disabled])
    |> validate_required([:name, :disabled])
  end
end
