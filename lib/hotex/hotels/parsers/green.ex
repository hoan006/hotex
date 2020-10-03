defmodule Hotex.Parsers.Green do
  @behaviour Hotex.Parsers

  defp trim(str), do: String.trim(str || "")

  def parse_hotel_id(entry), do: entry["id"]
  def parse_destination_id(entry), do: entry["destination"]
  def parse_name(entry), do: entry["name"] |> trim()

  def parse_location(entry) do
    %{
      lat: entry["lat"],
      lng: entry["lng"],
      address: entry["address"] |> trim()
    }
  end

  def parse_description(entry), do: entry["info"] |> trim()

  def parse_amenities(entry) do
    case entry["amenities"] do
      amenities when is_list(amenities) ->
        %{general: Enum.map(amenities, &trim/1)}

      # Just in case they have amenities by category in future
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
           |> Enum.map(&%{link: &1["url"], description: &1["description"] |> trim()})
           |> Enum.reject(&(&1.link in [nil, ""]))}
        end)

      _ ->
        %{}
    end
  end

  # No conditions from the sample yet
  def parse_booking_conditions(entry), do: []
end
