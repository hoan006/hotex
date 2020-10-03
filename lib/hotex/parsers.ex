defmodule Hotex.Parsers do
  @callback parse_hotel_id(map()) :: binary()
  @callback parse_destination_id(map()) :: binary()
  @callback parse_name(map()) :: binary()
  @callback parse_location(map()) :: map()
  @callback parse_description(map()) :: binary()
  @callback parse_amenities(map()) :: map()
  @callback parse_images(map()) :: map()
  @callback parse_booking_conditions(map()) :: list()

  def parse(supplier_code, entry) do
    with parser when not is_nil(parser) <- parser_for(:"#{supplier_code}"),
         hotel_id when hotel_id not in [nil, ""] <- parser.parse_hotel_id(entry),
         destination_id when destination_id not in [nil, ""] <- parser.parse_destination_id(entry) do
      [
        name: {:parse_name, :score_name},
        location: {:parse_location, :score_location},
        description: {:parse_description, :score_description},
        amenities: {:parse_amenities, :score_amenities},
        images: {:parse_images, :score_images},
        booking_conditions: {:parse_booking_conditions, :score_booking_conditions}
      ]
      |> Enum.reduce([], fn {field, {parse_func, score_func}}, acc ->
        value = apply(parser, parse_func, [entry])
        score = apply(__MODULE__, score_func, [value])

        if score > 0 do
          [{hotel_id, destination_id, field, value, score} | acc]
        else
          acc
        end
      end)
    else
      _ -> []
    end
  end

  defp parser_for(:red), do: Hotex.Parsers.Red
  defp parser_for(:green), do: Hotex.Parsers.Green
  defp parser_for(:blue), do: Hotex.Parsers.Blue
  defp parser_for(_), do: nil

  # Longer hotel name, better score
  def score_name(name), do: String.length(name || "")

  # Award more score for location with geographic coordination, then physical addresss
  def score_location(location) do
    [lat: 10, lng: 10, address: 5, city: 2, country: 1]
    |> Enum.reduce(0, fn {field, score_value}, acc ->
      if location[field] not in [nil, ""], do: acc + score_value, else: acc
    end)
  end

  # Longer description, better score
  def score_description(description), do: String.length(description || "")

  # More amenities, better score
  def score_amenities(amenities_map) do
    Enum.reduce(amenities_map, 0, fn {_, amenities}, acc ->
      acc + length(amenities)
    end)
  end

  # More images, better score. Images with description are better.
  def score_images(images_map) do
    Enum.reduce(images_map, 0, fn {_, images}, acc ->
      acc +
        length(images) * 10 +
        length(Enum.reject(images, &(&1[:description] in [nil, ""]))) * 3
    end)
  end

  # More conditions, better score
  def score_booking_conditions(conditions), do: length(conditions || [])
end
