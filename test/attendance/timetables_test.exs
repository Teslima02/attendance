defmodule Attendance.TimetablesTest do
  use Attendance.DataCase

  alias Attendance.Timetables

  describe "timetables" do
    alias Attendance.Timetables.Timetable

    import Attendance.TimetablesFixtures

    @invalid_attrs %{disabled: nil, end_time: nil, start_time: nil}

    test "list_timetables/0 returns all timetables" do
      timetable = timetable_fixture()
      assert Timetables.list_timetables() == [timetable]
    end

    test "get_timetable!/1 returns the timetable with given id" do
      timetable = timetable_fixture()
      assert Timetables.get_timetable!(timetable.id) == timetable
    end

    test "create_timetable/1 with valid data creates a timetable" do
      valid_attrs = %{disabled: true, end_time: ~T[14:00:00], start_time: ~T[14:00:00]}

      assert {:ok, %Timetable{} = timetable} = Timetables.create_timetable(valid_attrs)
      assert timetable.disabled == true
      assert timetable.end_time == ~T[14:00:00]
      assert timetable.start_time == ~T[14:00:00]
    end

    test "create_timetable/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timetables.create_timetable(@invalid_attrs)
    end

    test "update_timetable/2 with valid data updates the timetable" do
      timetable = timetable_fixture()
      update_attrs = %{disabled: false, end_time: ~T[15:01:01], start_time: ~T[15:01:01]}

      assert {:ok, %Timetable{} = timetable} = Timetables.update_timetable(timetable, update_attrs)
      assert timetable.disabled == false
      assert timetable.end_time == ~T[15:01:01]
      assert timetable.start_time == ~T[15:01:01]
    end

    test "update_timetable/2 with invalid data returns error changeset" do
      timetable = timetable_fixture()
      assert {:error, %Ecto.Changeset{}} = Timetables.update_timetable(timetable, @invalid_attrs)
      assert timetable == Timetables.get_timetable!(timetable.id)
    end

    test "delete_timetable/1 deletes the timetable" do
      timetable = timetable_fixture()
      assert {:ok, %Timetable{}} = Timetables.delete_timetable(timetable)
      assert_raise Ecto.NoResultsError, fn -> Timetables.get_timetable!(timetable.id) end
    end

    test "change_timetable/1 returns a timetable changeset" do
      timetable = timetable_fixture()
      assert %Ecto.Changeset{} = Timetables.change_timetable(timetable)
    end
  end
end
