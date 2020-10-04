# This is just a Postgres view
defmodule Hotex.Hotels.Hotel do
  use Ecto.Schema

  @primary_key false
  schema "hotels" do
    field :hotel_id, :string
    field :amenities, :map
    field :booking_conditions, {:array, :string}
    field :description, :string
    field :destination_id, :integer
    field :images, :map
    field :location, :map
    field :name, :string
  end
end
