defmodule AttendanceApi.Types.Student do
  use Absinthe.Schema.Notation

  alias AttendanceApi.Resolvers

  @desc "List student attendance Object"
  object :list_student_attendances do
    field :attendances, list_of(:student_attendance)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
    field :distance, :integer
    field :sort_field, :string
    field :sort_direction, :string
  end

  @desc "student attendance input"
  input_object :student_attendance_filter_input do
    field :attendance_time, :datetime
    field :status, :boolean
    field :course_id, :string
    field :student_id, :string
    field :lecturer_attendance_id, :string
  end

  @desc "get student attendance input"
  input_object :get_student_attendance_input do
    field :page, :integer, default_value: 1
    field :page_size, :integer, default_value: 15
    field :sort_field, :string, default_value: "inserted_at"
    field :sort_direction, :string, default_value: "desc"
    field :attendance, :student_attendance_filter_input, default_value: %{}
  end

  @desc "Attendance object"
  object :attendance do
    field :id, :id
    field :active, :boolean
    field :start_time, :datetime
    field :end_time, :datetime
    field :class, :class
    field :course, :lecturer_courses
    field :lecturer, :lecturer
  end

  @desc "Program filter input Object"
  input_object :attendance_filter_input do
    field :class_id, non_null(:string)
    field :active, :boolean, default_value: true
    field :program_id, non_null(:string)
  end

  @desc "Attendance input object"
  input_object :get_current_attendance_input do
    field :page, :integer, default_value: 1
    field :page_size, :integer, default_value: 15
    field :sort_field, :string, default_value: "inserted_at"
    field :sort_direction, :string, default_value: "desc"
    field :attendance, :attendance_filter_input, default_value: %{}
  end

  @desc "student mark attendance input"
  input_object :student_mark_attendance_input do
    field :attendance_time, :datetime
    field :course_id, :string
    field :lecturer_attendance_id, :string
  end

  @desc "student attendance object"
  object :student_attendance do
    field :id, :id
    field :status, :boolean
    field :attendance_time, :datetime
    field :course, :student_courses
    field :student, :student
    field :lecturer_attendance, :lecturer_attendance
  end

  @desc "course object"
  object :student_courses do
    field :id, :id
    field :code, :string
    field :description, :string
    field :name, :string
  end

  @desc "Student login input"
  input_object :student_login_input do
    field :matric_number, non_null(:string)
    field :password, non_null(:string)
  end

  @desc "Student login object"
  object :student_login_object do
    field :student, :student
    field :token, :string
  end

  @desc "Student object"
  object :student do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :matric_number, :string
    field :class, :class
    field :account_type, :class
  end

  object :student_mutation do
    @desc """
    Student login.
    """
    field :student_login, :student_login_object do
      arg(:input, non_null(:student_login_input))
      resolve(&Resolvers.Student.student_login/2)
    end

    @desc """
    Student mark attendance.
    """
    field :student_mark_attendance, :student_attendance do
      middleware(AttendanceApi.Middleware.StudentAuth)
      arg(:input, non_null(:student_mark_attendance_input))
      resolve(&Resolvers.Student.mark_attendance/2)
    end
  end

  object :student_queries do
    @desc """
    Current student details
    """
    field :current_student, :student do
      middleware(AttendanceApi.Middleware.StudentAuth)
      resolve(&Resolvers.Student.get_current_student/2)
    end

    @desc """
    Get student courses
    """
    field :student_courses, list_of(:student_courses) do
      middleware(AttendanceApi.Middleware.StudentAuth)
      resolve(&Resolvers.Student.get_student_courses/2)
    end

    @desc """
    Get all current attendances
    """
    field :current_attendances, list_of(:attendance) do
      middleware(AttendanceApi.Middleware.StudentAuth)
      arg(:input, non_null(:get_current_attendance_input))
      resolve(&Resolvers.Student.get_current_attendances/2)
    end

    @desc """
    Get all attendances history
    """
    field :list_student_attendances_history, :list_student_attendances do
      middleware(AttendanceApi.Middleware.StudentAuth)
      arg(:input, non_null(:get_student_attendance_input))
      resolve(&Resolvers.Student.get_student_attendances/2)
    end

    @desc """
    Get list of lecturer notifications history.
    """
    field :list_student_notification_history, :list_lecturer_notifications_history do
      middleware(AttendanceApi.Middleware.StudentAuth)
      arg(:input, :get_lecturer_notification_input)
      resolve(&Resolvers.Student.notification_history/2)
    end
  end
end
