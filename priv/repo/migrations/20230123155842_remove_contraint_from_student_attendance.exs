defmodule Attendance.Repo.Migrations.RemoveContraintFromStudentAttendance do
  use Ecto.Migration

  # def change do
  #   drop constraint(:foo, "foo_bar_id_fkey")

  #   alter table(:foo) do
  #     modify :bar_id, references(:bar, on_delete: :delete_all), from: references(:bar, on_delete: :nothing)
  #   end
  # end

  def change do
    alter table(:student_attendances) do
      modify :student_id, references(:students, on_delete: :delete_all),
        from: references(:students, on_delete: :nothing)

      modify :course_id, references(:courses, on_delete: :delete_all),
        from: references(:courses, on_delete: :nothing)

      modify :lecturer_attendance_id, references(:lecturer_attendances, on_delete: :delete_all),
        from: references(:lecturer_attendances, on_delete: :delete_all)
    end
  end
end
