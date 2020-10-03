defmodule Hotex.Hotels do
  @moduledoc """
  The Hotels context.
  """

  import Ecto.Query, warn: false
  alias Hotex.Repo

  alias Hotex.Hotels.Supplier

  @doc """
  Returns the list of suppliers.

  ## Examples

      iex> list_suppliers()
      [%Supplier{}, ...]

  """
  def list_suppliers do
    Repo.all(Supplier)
  end

  @doc """
  Gets a single supplier.

  Raises `Ecto.NoResultsError` if the Supplier does not exist.

  ## Examples

      iex> get_supplier!(123)
      %Supplier{}

      iex> get_supplier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_supplier!(id), do: Repo.get!(Supplier, id)

  @doc """
  Creates a supplier.

  ## Examples

      iex> create_supplier(%{field: value})
      {:ok, %Supplier{}}

      iex> create_supplier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_supplier(attrs \\ %{}) do
    %Supplier{}
    |> Supplier.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a supplier.

  ## Examples

      iex> update_supplier(supplier, %{field: new_value})
      {:ok, %Supplier{}}

      iex> update_supplier(supplier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_supplier(%Supplier{} = supplier, attrs) do
    supplier
    |> Supplier.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a supplier.

  ## Examples

      iex> delete_supplier(supplier)
      {:ok, %Supplier{}}

      iex> delete_supplier(supplier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_supplier(%Supplier{} = supplier) do
    Repo.delete(supplier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking supplier changes.

  ## Examples

      iex> change_supplier(supplier)
      %Ecto.Changeset{source: %Supplier{}}

  """
  def change_supplier(%Supplier{} = supplier) do
    Supplier.changeset(supplier, %{})
  end

  alias Hotex.Hotels.HotelAttribute

  @doc """
  Returns the list of hotel_attributes.

  ## Examples

      iex> list_hotel_attributes()
      [%HotelAttribute{}, ...]

  """
  def list_hotel_attributes do
    Repo.all(HotelAttribute)
  end

  @doc """
  Gets a single hotel_attribute.

  Raises `Ecto.NoResultsError` if the Hotel attribute does not exist.

  ## Examples

      iex> get_hotel_attribute!(123)
      %HotelAttribute{}

      iex> get_hotel_attribute!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hotel_attribute!(id), do: Repo.get!(HotelAttribute, id)

  @doc """
  Creates a hotel_attribute.

  ## Examples

      iex> create_hotel_attribute(%{field: value})
      {:ok, %HotelAttribute{}}

      iex> create_hotel_attribute(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hotel_attribute(attrs \\ %{}) do
    %HotelAttribute{}
    |> HotelAttribute.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hotel_attribute.

  ## Examples

      iex> update_hotel_attribute(hotel_attribute, %{field: new_value})
      {:ok, %HotelAttribute{}}

      iex> update_hotel_attribute(hotel_attribute, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hotel_attribute(%HotelAttribute{} = hotel_attribute, attrs) do
    hotel_attribute
    |> HotelAttribute.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hotel_attribute.

  ## Examples

      iex> delete_hotel_attribute(hotel_attribute)
      {:ok, %HotelAttribute{}}

      iex> delete_hotel_attribute(hotel_attribute)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hotel_attribute(%HotelAttribute{} = hotel_attribute) do
    Repo.delete(hotel_attribute)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hotel_attribute changes.

  ## Examples

      iex> change_hotel_attribute(hotel_attribute)
      %Ecto.Changeset{source: %HotelAttribute{}}

  """
  def change_hotel_attribute(%HotelAttribute{} = hotel_attribute) do
    HotelAttribute.changeset(hotel_attribute, %{})
  end
end
