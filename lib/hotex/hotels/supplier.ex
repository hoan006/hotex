defmodule Hotex.Hotels.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "suppliers" do
    field :name, :string
    field :parser_code, :string
    field :sample_input, :string

    timestamps()
  end

  @doc false
  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:name, :parser_code, :sample_input])
    |> validate_required([:name, :parser_code])
  end
end
