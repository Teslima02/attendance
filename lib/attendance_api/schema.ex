defmodule AttendanceApi.Schema do
  use Absinthe.Schema

  alias Attendance.Catalog.Program
  alias AttendanceApi.Types

  import_types(Absinthe.Type.Custom)
  import_types(Types.Lecturer)
  import_types(Types.Catalog)
  import_types(Types.Student)

  mutation do
    import_fields(:lecturer_mutation)
    import_fields(:student_mutation)
    import_fields(:lecturer_attendance_mutation)
  end

  query do
    import_fields(:lecturer_queries)
    import_fields(:program_queries)
    import_fields(:session_queries)
    import_fields(:semester_queries)

    import_fields(:student_queries)
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(Attendance.Repo)

    loader =
      Dataloader.new()
      |> Dataloader.add_source(Program, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
