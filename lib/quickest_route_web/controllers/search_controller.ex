defmodule QuickestRouteWeb.SearchController do
  use QuickestRouteWeb, :controller

  alias QuickestRoute.Search

  def new(conn, _params) do
    changeset = Search.form()
    render(conn, "new.html", changeset: changeset)
  end

  def run(conn, %{"parameters" => params}) do
    with {:ok, validated_params} <- Search.validate(params),
         {:ok, search_info} <- Search.convert(validated_params),
         ## TODO - need to work out how to deal with unrefined results and multiple results
         ## probably use the `else` to drive some view behavior
         ## ask user to try another input or select from the choices, respectively
         {:ok, refined_params} <- Search.refine(search_info),
         {:ok, completed_search} <- Search.search(refined_params) do
      response = prepare_response(completed_search)
      # passing a list of 3-tuples literally causes it to disapper
      # passing a map with a list containing maps breaks it too
      # this is because what you pass to the redirect must implement Phoenix.Param
      IO.inspect(response, label: "PREPARED RESULT")

      conn
      |> put_flash(:info, "Search submitted!")
      |> redirect(to: Routes.search_path(conn, :show, response))
    end
  end


  def show(conn, response) do
    # surprised to learn that the order of the list in the response
    # is not preserved in the redirect
    IO.inspect(response, label: "RESPONSE")
    sorted = Enum.sort_by(response, fn {_alternative, duration} -> duration end)
    IO.inspect(sorted, label: "SORTED")
    render(conn, "show.html", response: sorted)
  end

  defp prepare_response(%{durations: durations}) do
    Enum.map(
      durations,
      fn {%{refined: [%{"name" => origin_name}]}, %{refined: [%{"name" => alternative_name}]},
          duration} ->
        {alternative_name, duration}
      end
    )
  end
end
