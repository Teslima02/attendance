defmodule Attendance.Repo.Migrations.AddGeoLocationToLecturerHall do
  use Ecto.Migration

  def change do
    alter table(:lecturer_halls) do
      add :latitude, :string, default: "0.0", null: false
      add :longitude, :string, default: "0.0", null: false
    end
  end
end
