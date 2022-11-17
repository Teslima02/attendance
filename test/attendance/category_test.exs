defmodule Attendance.CategoryTest do
  use Attendance.DataCase

  alias Attendance.Category

  describe "course" do
    alias Attendance.Category.Courses

    import Attendance.CategoryFixtures

    @invalid_attrs %{code: nil, description: nil, name: nil}

    test "list_course/0 returns all course" do
      courses = courses_fixture()
      assert Category.list_course() == [courses]
    end

    test "get_courses!/1 returns the courses with given id" do
      courses = courses_fixture()
      assert Category.get_courses!(courses.id) == courses
    end

    test "create_courses/1 with valid data creates a courses" do
      valid_attrs = %{code: "some code", description: "some description", name: "some name"}

      assert {:ok, %Courses{} = courses} = Category.create_courses(valid_attrs)
      assert courses.code == "some code"
      assert courses.description == "some description"
      assert courses.name == "some name"
    end

    test "create_courses/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Category.create_courses(@invalid_attrs)
    end

    test "update_courses/2 with valid data updates the courses" do
      courses = courses_fixture()
      update_attrs = %{code: "some updated code", description: "some updated description", name: "some updated name"}

      assert {:ok, %Courses{} = courses} = Category.update_courses(courses, update_attrs)
      assert courses.code == "some updated code"
      assert courses.description == "some updated description"
      assert courses.name == "some updated name"
    end

    test "update_courses/2 with invalid data returns error changeset" do
      courses = courses_fixture()
      assert {:error, %Ecto.Changeset{}} = Category.update_courses(courses, @invalid_attrs)
      assert courses == Category.get_courses!(courses.id)
    end

    test "delete_courses/1 deletes the courses" do
      courses = courses_fixture()
      assert {:ok, %Courses{}} = Category.delete_courses(courses)
      assert_raise Ecto.NoResultsError, fn -> Category.get_courses!(courses.id) end
    end

    test "change_courses/1 returns a courses changeset" do
      courses = courses_fixture()
      assert %Ecto.Changeset{} = Category.change_courses(courses)
    end
  end
end
