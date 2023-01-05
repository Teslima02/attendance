defmodule Attendance.Lecturer_attendancesTest do
  use Attendance.DataCase

  alias Attendance.Lecturer_attendances

  describe "lecturer_attendances" do
    alias Attendance.Lecturer_attendances.Lecturer_attendance

    import Attendance.Lecturer_attendancesFixtures

    @invalid_attrs %{end_date: nil, start_date: nil, status: nil}

    test "list_lecturer_attendances/0 returns all lecturer_attendances" do
      lecturer_attendance = lecturer_attendance_fixture()
      assert Lecturer_attendances.list_lecturer_attendances() == [lecturer_attendance]
    end

    test "get_lecturer_attendance!/1 returns the lecturer_attendance with given id" do
      lecturer_attendance = lecturer_attendance_fixture()
      assert Lecturer_attendances.get_lecturer_attendance!(lecturer_attendance.id) == lecturer_attendance
    end

    test "create_lecturer_attendance/1 with valid data creates a lecturer_attendance" do
      valid_attrs = %{end_date: ~N[2023-01-03 03:14:00], start_date: ~N[2023-01-03 03:14:00], status: true}

      assert {:ok, %Lecturer_attendance{} = lecturer_attendance} = Lecturer_attendances.create_lecturer_attendance(valid_attrs)
      assert lecturer_attendance.end_date == ~N[2023-01-03 03:14:00]
      assert lecturer_attendance.start_date == ~N[2023-01-03 03:14:00]
      assert lecturer_attendance.status == true
    end

    test "create_lecturer_attendance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lecturer_attendances.create_lecturer_attendance(@invalid_attrs)
    end

    test "update_lecturer_attendance/2 with valid data updates the lecturer_attendance" do
      lecturer_attendance = lecturer_attendance_fixture()
      update_attrs = %{end_date: ~N[2023-01-04 03:14:00], start_date: ~N[2023-01-04 03:14:00], status: false}

      assert {:ok, %Lecturer_attendance{} = lecturer_attendance} = Lecturer_attendances.update_lecturer_attendance(lecturer_attendance, update_attrs)
      assert lecturer_attendance.end_date == ~N[2023-01-04 03:14:00]
      assert lecturer_attendance.start_date == ~N[2023-01-04 03:14:00]
      assert lecturer_attendance.status == false
    end

    test "update_lecturer_attendance/2 with invalid data returns error changeset" do
      lecturer_attendance = lecturer_attendance_fixture()
      assert {:error, %Ecto.Changeset{}} = Lecturer_attendances.update_lecturer_attendance(lecturer_attendance, @invalid_attrs)
      assert lecturer_attendance == Lecturer_attendances.get_lecturer_attendance!(lecturer_attendance.id)
    end

    test "delete_lecturer_attendance/1 deletes the lecturer_attendance" do
      lecturer_attendance = lecturer_attendance_fixture()
      assert {:ok, %Lecturer_attendance{}} = Lecturer_attendances.delete_lecturer_attendance(lecturer_attendance)
      assert_raise Ecto.NoResultsError, fn -> Lecturer_attendances.get_lecturer_attendance!(lecturer_attendance.id) end
    end

    test "change_lecturer_attendance/1 returns a lecturer_attendance changeset" do
      lecturer_attendance = lecturer_attendance_fixture()
      assert %Ecto.Changeset{} = Lecturer_attendances.change_lecturer_attendance(lecturer_attendance)
    end
  end
end
