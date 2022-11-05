defmodule Attendance.Catalog.Program do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:id, :binary_id, autogenerate: true}
  # @foreign_key_type :binary_id
  schema "programs" do
    field :description, :string
    field :disabled, :boolean, default: false
    field :name, :string
    belongs_to :admin, Attendance.Accounts.Admin

    timestamps()
  end

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, [:name, :description, :disabled])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end
end
