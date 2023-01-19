defmodule AttendanceApi.Types.Lecturer do
  use Absinthe.Schema.Notation

  alias Hex.Resolver
  alias AttendanceApi.Resolvers
  alias AttendanceApi.Topics.Topics

  @desc "notification object"
  object :notification do
    field :id, :id
    field :description, :string
    field :class, :class
    field :lecturer, :lecturer
    field :course, :lecturer_courses
    field :inserted_at, :datetime
  end

  @desc "notification input"
  input_object :notification_input do
    field :description, :string
    field :class_id, :string
    field :course_id, :string
  end

  @desc "period object"
  object :period do
    field :id, :id
    field :start_time, :time
    field :end_time, :time
  end

  @desc "Days of the week object"
  object :days_of_week do
    field :id, :id
    field :name, :string
  end

  @desc "Timetable period object"
  object :lecturer_timetable do
    field :id, :id
    field :start_time, :period
    field :end_time, :period
    field :days_of_week, :days_of_week
    field :course, :lecturer_courses
    field :lecture_hall, :string
    field :semester, :semester
  end

  @desc "Class input"
  input_object :class_input do
    field :class_id, :string
  end

  @desc "Course input"
  input_object :course_input do
    field :course_id, :string
  end

  @desc "attendance input"
  input_object :lecturer_attendance_input do
    field :semester_id, :string
    field :class_id, :string
    field :program_id, :string
    field :course_id, :string
    field :start_date, :datetime
    field :end_date, :datetime
  end

  @desc "attendance object"
  object :lecturer_attendance do
    field :semester, :semester
    field :class, :class
    field :program, :program
    field :course, :lecturer_courses
    field :start_date, :datetime
    field :end_date, :datetime
    field :active, :boolean
    field :id, :id
  end

  @desc "class object"
  object :class do
    field :id, :id
    field :name, :string
    field :disabled, :boolean
  end

  @desc "course filter input"
  input_object :lecturer_courses_filter_input do
    field :session_id, :string
    field :program_id, :string
    field :class_id, :string
    field :semester_id, :string
  end

  @desc "course object"
  object :lecturer_courses do
    field :id, :id
    field :code, :string
    field :description, :string
    field :name, :string
  end

  @desc "Lecturer login input"
  input_object :lecturer_login do
    field :matric_number, non_null(:string)
    field :password, non_null(:string)
  end

  @desc "Lecturer login object"
  object :lecturer_login_object do
    field :lecturer, :lecturer
    field :token, :string
  end

  @desc "List lecturers object"
  object :lecturer do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :matric_number, :string
  end

  object :lecturer_mutation do
    @desc """
    Lecturer login.
    """
    field :lecturer_login, :lecturer_login_object do
      arg(:input, non_null(:lecturer_login))
      resolve(&Resolvers.Lecturer.lecturer_login/2)
    end
  end

  object :lecturer_attendance_mutation do
    @desc """
    Lecturer attendance.
    """
    field :lecturer_attendance, :lecturer_attendance do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, non_null(:lecturer_attendance_input))
      resolve(&Resolvers.Lecturer.create_lecturer_attendance/2)
    end

    @desc """
    Lecturer send notification.
    """
    field :send_notification, :notification do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, non_null(:notification_input))
      resolve(&Resolvers.Lecturer.create_notification/2)
    end
  end

  object :lecturer_attendance_subscription do
    @desc """
    Lecturer open attendance.
    """
    field :lecturer_open_attendance, :lecturer_attendance do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, non_null(:course_input))

      config(fn %{input: input}, _info ->
        {:ok, topic: "#{Topics.lecturer_open_attendance()}:#{input.course_id}"}
      end)

      # trigger [:create_lecturer_attendance], topic: fn lecturer_open_attendance ->
      #   IO.inspect "trigger create lecturer open attendance"
      #   IO.inspect lecturer_open_attendance
      #   # "#{lecturer_open_attendance.class_id}:#{Topics.lecturer_open_attendance()}"
      #   _ -> []
      # end

      resolve(fn open_attendance, _, _ ->
        {:ok, open_attendance}
      end)
    end

    @desc """
    Lecturer send notification.
    """
    field :send_notification_message, :notification do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      arg(:input, non_null(:class_input))

      config(fn %{input: input}, _info ->
        {:ok, topic: "#{Topics.lecturer_send_notification()}:#{input.class_id}"}
      end)

      resolve(fn notification, _, _ ->
        {:ok, notification}
      end)
    end
  end

  object :lecturer_queries do
    @desc """
    Get lecturer current period.
    """
    field :lecturer_current_period, :lecturer_timetable do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_lecturer_current_period/2)
    end

    @desc """
    Get lecturer daily period.
    """
    field :lecturer_daily_period, list_of(:lecturer_timetable) do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_lecturer_daily_period/2)
    end

    @desc """
    Get lecturer next period.
    """
    field :lecturer_next_period, :lecturer_timetable do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_lecturer_next_period/2)
    end

    @desc """
    Get list of lecturers.
    """
    field :list_lecturers, list_of(:lecturer) do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.list_lecturers/2)
    end

    @desc """
    Current lecturer details
    """
    field :current_lecturer, :lecturer do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_current_lecturer/2)
    end

    @desc """
    Get lecturer courses
    """
    field :lecturer_courses, list_of(:lecturer_courses) do
      arg(:input, :lecturer_courses_filter_input)
      middleware(AttendanceApi.Middleware.LecturerAuth)
      resolve(&Resolvers.Lecturer.get_lecturer_courses/2)
    end

    @desc """
    Get list of notification.
    """
    field :list_notifications, list_of(:notification) do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      # resolve(&Resolvers.Lecturer.list_lecturers/2)
    end

    @desc """
    Get list of attendances.
    """
    field :list_attendance, list_of(:attendance) do
      middleware(AttendanceApi.Middleware.LecturerAuth)
      # resolve(&Resolvers.Lecturer.list_lecturers/2)
    end
  end
end
