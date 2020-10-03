defmodule HotexWeb.PageController do
  use HotexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", suppliers: Hotex.Hotels.list_suppliers())
  end

  def add_hotels(conn, params) do
    with {:invalid_params, %{"supplier_id" => supplier_id, "url" => url}}
         when supplier_id not in [nil, ""] and url not in [nil, ""] <-
           {:invalid_params, params},
         {:invalid_params, supplier} when not is_nil(supplier) <-
           {:invalid_params, Hotex.Repo.get(Hotex.Hotels.Supplier, supplier_id)},
         {:ok, response} <- Tesla.get(url),
         {:ok, response} <- Jason.decode(response.body) do
      entries = if is_list(response), do: response, else: [response]

      parse_result =
        Enum.map(entries, &Hotex.Parsers.parse(supplier.parser_code, &1))
        |> Enum.reject(&is_nil/1)
        |> IO.inspect()

      json(conn, "Added #{length(parse_result)} entries")
    else
      {code, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{code: code, message: "Failed with code #{code}"})

      {:error, code} when is_atom(code) ->
        conn
        |> put_status(:bad_request)
        |> json(%{code: code, message: "Failed with code #{code}"})

      error ->
        conn
        |> put_status(:server_error)
        |> json(%{code: :unexpected_error, message: "Unexpected error #{inspect(error)}"})
    end
  end
end
