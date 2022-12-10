defmodule Attendance.Lecturer_hallsTest do
  use Attendance.DataCase

  alias Attendance.Lecturer_halls

  describe "lecturer_halls" do
    alias Attendance.Lecturer_halls.Lecturer_hall

    import Attendance.Lecturer_hallsFixtures

    @invalid_attrs %{building_name: nil, disabled: nil, hall_number: nil}

    test "list_lecturer_halls/0 returns all lecturer_halls" do
      lecturer_hall = lecturer_hall_fixture()
      assert Lecturer_halls.list_lecturer_halls() == [lecturer_hall]
    end

    test "get_lecturer_hall!/1 returns the lecturer_hall with given id" do
      lecturer_hall = lecturer_hall_fixture()
      assert Lecturer_halls.get_lecturer_hall!(lecturer_hall.id) == lecturer_hall
    end

    test "create_lecturer_hall/1 with valid data creates a lecturer_hall" do
      valid_attrs = %{building_name: "some building_name", disabled: true, hall_number: "some hall_number"}

      assert {:ok, %Lecturer_hall{} = lecturer_hall} = Lecturer_halls.create_lecturer_hall(valid_attrs)
      assert lecturer_hall.building_name == "some building_name"
      assert lecturer_hall.disabled == true
      assert lecturer_hall.hall_number == "some hall_number"
    end

    test "create_lecturer_hall/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lecturer_halls.create_lecturer_hall(@invalid_attrs)
    end

    test "update_lecturer_hall/2 with valid data updates the lecturer_hall" do
      lecturer_hall = lecturer_hall_fixture()
      update_attrs = %{building_name: "some updated building_name", disabled: false, hall_number: "some updated hall_number"}

      assert {:ok, %Lecturer_hall{} = lecturer_hall} = Lecturer_halls.update_lecturer_hall(lecturer_hall, update_attrs)
      assert lecturer_hall.building_name == "some updated building_name"
      assert lecturer_hall.disabled == false
      assert lecturer_hall.hall_number == "some updated hall_number"
    end

    test "update_lecturer_hall/2 with invalid data returns error changeset" do
      lecturer_hall = lecturer_hall_fixture()
      assert {:error, %Ecto.Changeset{}} = Lecturer_halls.update_lecturer_hall(lecturer_hall, @invalid_attrs)
      assert lecturer_hall == Lecturer_halls.get_lecturer_hall!(lecturer_hall.id)
    end

    test "delete_lecturer_hall/1 deletes the lecturer_hall" do
      lecturer_hall = lecturer_hall_fixture()
      assert {:ok, %Lecturer_hall{}} = Lecturer_halls.delete_lecturer_hall(lecturer_hall)
      assert_raise Ecto.NoResultsError, fn -> Lecturer_halls.get_lecturer_hall!(lecturer_hall.id) end
    end

    test "change_lecturer_hall/1 returns a lecturer_hall changeset" do
      lecturer_hall = lecturer_hall_fixture()
      assert %Ecto.Changeset{} = Lecturer_halls.change_lecturer_hall(lecturer_hall)
    end
  end
end
