defmodule Hotex.Parsers.Blue do
  @behaviour Hotex.Parsers

  defp trim(str), do: String.trim(str || "")

  def parse_hotel_id(entry), do: entry["hotel_id"]
  def parse_destination_id(entry), do: entry["destination_id"]
  def parse_name(entry), do: entry["hotel_name"] |> trim()

  def parse_location(entry) do
    %{
      address: entry["location"]["address"] |> trim(),
      country: entry["location"]["country"] |> trim()
    }
  end

  def parse_description(entry), do: entry["details"] |> trim()

  def parse_amenities(entry) do
    case entry["amenities"] do
      amenity_map when is_map(amenity_map) ->
        Enum.into(amenity_map, %{}, fn {category, amenities} ->
          {category, Enum.map(amenities, &trim/1)}
        end)

      _ ->
        %{}
    end
  end

  def parse_images(entry) do
    case entry["images"] do
      image_map when is_map(image_map) ->
        Enum.into(image_map, %{}, fn {category, images} ->
          {category,
           images
           |> Enum.map(&%{link: &1["link"], description: &1["description"] |> trim()})
           |> Enum.reject(&(&1.link in [nil, ""]))}
        end)

      _ ->
        %{}
    end
  end

  def parse_booking_conditions(entry) do
    Enum.map(entry["booking_conditions"] || [], &trim/1)
  end
end
