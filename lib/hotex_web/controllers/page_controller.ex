defmodule HotexWeb.PageController do
  use HotexWeb, :controller
  import Ecto.Query, only: [from: 2, where: 3]

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

      if length(parse_result) > 0 do
        hotel_attributes =
          parse_result
          |> List.flatten()
          |> Enum.map(fn {hotel_id, field, value, score} ->
            Hotex.Hotels.HotelAttribute.changeset(
              %Hotex.Hotels.HotelAttribute{},
              %{
                hotel_id: hotel_id,
                field: field |> to_string(),
                value: Jason.encode!(value),
                score: score,
                supplier_id: supplier.id
              }
            )
            |> Ecto.Changeset.apply_changes()
            |> Map.take([:hotel_id, :field, :value, :score, :supplier_id])
            |> Map.merge(%{
              inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
              updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
            })
          end)

        Hotex.Repo.insert_all(
          Hotex.Hotels.HotelAttribute,
          hotel_attributes,
          on_conflict: :replace_all,
          conflict_target: [:hotel_id, :supplier_id, :field]
        )

        Hotex.Repo.query("REFRESH MATERIALIZED VIEW hotels")
      end

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

  defmacro where_if(query, condition, expr1, expr2) do
    quote do
      if !unquote(condition) do
        unquote(query)
      else
        where(unquote(query), unquote(expr1), unquote(expr2))
      end
    end
  end

  def find_hotels(conn, params) do
    limit =
      case Integer.parse(params["limit"] || "1000") do
        {limit, _} when limit >= 0 and limit <= 1000 -> limit
        _ -> 100
      end

    offset =
      case Integer.parse(params["offset"] || "0") do
        {offset, _} when offset >= 0 -> offset
        _ -> 0
      end

    destination_id = params["destination_id"]

    destination_id =
      if destination_id in [nil, ""] do
        nil
      else
        case Integer.parse(destination_id) do
          {destination_id, _} -> destination_id
          _ -> -1
        end
      end

    query =
      from(h in Hotex.Hotels.Hotel, [])
      |> where_if(
        not is_nil(destination_id),
        [h],
        h.destination_id == ^destination_id
      )
      |> where_if(
        params["hotel_id"] not in [nil, ""],
        [h],
        h.hotel_id in ^(params["hotel_id"] |> String.split(",") |> Enum.map(&String.trim/1))
      )

    q = String.trim(params["q"] || "")

    # For text search, the search string may appear in attributes who are not part of hotels due to lower score
    {query, overridden_value_map} =
      if q != "" do
        overridden_value_map =
          from(a in Hotex.Hotels.HotelAttribute,
            where: ilike(a.value, ^"%#{String.replace(q, "%", "\\%")}%"),
            distinct: [:hotel_id, :field],
            order_by: [desc: :score]
          )
          |> Hotex.Repo.all()
          |> Enum.reduce(%{}, fn attribute, acc ->
            Map.update(
              acc,
              attribute.hotel_id,
              %{attribute.field => attribute.value},
              &Map.put(&1, attribute.field, attribute.value)
            )
          end)

        query = query |> where([h], h.hotel_id in ^Map.keys(overridden_value_map))
        {query, overridden_value_map}
      else
        {query, %{}}
      end

    total = query |> Hotex.Repo.aggregate(:count)

    data =
      from(h in query, limit: ^limit, offset: ^offset)
      |> Hotex.Repo.all()
      |> Enum.map(&Map.drop(&1, [:__struct__, :__meta__]))
      |> Enum.map(fn datum ->
        Enum.reduce(overridden_value_map[datum.hotel_id] || %{}, datum, fn {field, value}, acc ->
          Map.put(acc, field, Jason.decode!(value))
        end)
      end)

    json(conn, %{data: data, count: length(data), total: total, limit: limit, offset: offset})
  end
end
