defmodule Hotex.Parsers.Red do
  @behaviour Hotex.Parsers

  defp trim(str), do: String.trim(str || "")

  def parse_hotel_id(entry), do: entry["Id"]
  def parse_destination_id(entry), do: entry["DestinationId"]
  def parse_name(entry), do: entry["Name"] |> trim()

  def parse_location(entry) do
    %{
      lat: entry["Latitude"],
      lng: entry["Longitude"],
      address: entry["Address"] |> trim(),
      city: entry["City"] |> trim(),
      country: entry["Country"] |> trim()
    }
  end

  def parse_description(entry), do: entry["Description"] |> trim()

  def parse_amenities(entry) do
    case entry["Facilities"] do
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

  # No images in the sample yet
  def parse_images(_entry), do: %{}

  # No booking condition in the sample yet
  def parse_booking_conditions(_entry), do: []
end
