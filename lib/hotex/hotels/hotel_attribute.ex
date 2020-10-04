defmodule Hotex.Hotels.HotelAttribute do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hotel_attributes" do
    field :field, :string
    field :hotel_id, :string
    field :value, :string
    field :score, :integer
    belongs_to :supplier, Hotex.Hotels.Supplier

    timestamps()
  end

  @doc false
  def changeset(hotel_attribute, attrs) do
    hotel_attribute
    |> cast(attrs, [:hotel_id, :field, :value, :score, :supplier_id])
    |> validate_required([:hotel_id, :field, :value])
  end
end
