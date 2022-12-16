defmodule AttendanceApi.Schema do
  use Absinthe.Schema

  alias AttendanceApi.Types

  import_types(Types.Lecturer)

  mutation do
    import_fields(:lecturer_mutation)
  end

  query do
    import_fields(:lecturer_queries)
  end
end
