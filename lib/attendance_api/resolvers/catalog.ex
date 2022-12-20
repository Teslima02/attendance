defmodule AttendanceApi.Resolvers.Catalog do
  alias Attendance.Catalog

  def list_programs(%{input: input_params |> IO.inspect()}, %{
        context: %{current_lecturer: current_lecturer}
      }) do
    with {:ok, page} <- Catalog.paginate_programs(input_params) do
      {:ok, page}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error,
         message: "An error occurred while getting programs",
         details: Attendance.Errors.GraphqlErrors.transform_errors(changeset)}
    end
  end
end
