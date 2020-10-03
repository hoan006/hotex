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
        entries
        |> Enum.map(&Hotex.Parsers.parse(supplier.parser_code, &1))
        |> Enum.reject(&(&1 == []))

      hotel_attributes =
        parse_result
        |> List.flatten()
        |> Enum.map(fn {hotel_id, destination_id, field, value, score} ->
          Hotex.Hotels.HotelAttribute.changeset(
            %Hotex.Hotels.HotelAttribute{},
            %{
              hotel_id: hotel_id,
              destination_id: destination_id |> to_string(),
              field: field |> to_string(),
              value: Jason.encode!(value),
              score: score,
              supplier_id: supplier.id
            }
          )
          |> Ecto.Changeset.apply_changes()
          |> Map.take([:hotel_id, :destination_id, :field, :value, :score, :supplier_id])
          |> Map.merge(%{
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          })
        end)

      Hotex.Repo.insert_all(
        Hotex.Hotels.HotelAttribute,
        hotel_attributes,
        on_conflict: :replace_all,
        conflict_target: [:hotel_id, :destination_id, :supplier_id, :field]
      )

      json(conn, %{message: "#{length(parse_result)} entries added"})
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
