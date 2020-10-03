defmodule Hotex.HotelsTest do
  use Hotex.DataCase

  alias Hotex.Hotels

  describe "suppliers" do
    alias Hotex.Hotels.Supplier

    @valid_attrs %{name: "some name", parser_code: "some parser_code"}
    @update_attrs %{name: "some updated name", parser_code: "some updated parser_code"}
    @invalid_attrs %{name: nil, parser_code: nil}

    def supplier_fixture(attrs \\ %{}) do
      {:ok, supplier} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Hotels.create_supplier()

      supplier
    end

    test "list_suppliers/0 returns all suppliers" do
      supplier = supplier_fixture()
      assert Hotels.list_suppliers() == [supplier]
    end

    test "get_supplier!/1 returns the supplier with given id" do
      supplier = supplier_fixture()
      assert Hotels.get_supplier!(supplier.id) == supplier
    end

    test "create_supplier/1 with valid data creates a supplier" do
      assert {:ok, %Supplier{} = supplier} = Hotels.create_supplier(@valid_attrs)
      assert supplier.name == "some name"
      assert supplier.parser_code == "some parser_code"
    end

    test "create_supplier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hotels.create_supplier(@invalid_attrs)
    end

    test "update_supplier/2 with valid data updates the supplier" do
      supplier = supplier_fixture()
      assert {:ok, %Supplier{} = supplier} = Hotels.update_supplier(supplier, @update_attrs)
      assert supplier.name == "some updated name"
      assert supplier.parser_code == "some updated parser_code"
    end

    test "update_supplier/2 with invalid data returns error changeset" do
      supplier = supplier_fixture()
      assert {:error, %Ecto.Changeset{}} = Hotels.update_supplier(supplier, @invalid_attrs)
      assert supplier == Hotels.get_supplier!(supplier.id)
    end

    test "delete_supplier/1 deletes the supplier" do
      supplier = supplier_fixture()
      assert {:ok, %Supplier{}} = Hotels.delete_supplier(supplier)
      assert_raise Ecto.NoResultsError, fn -> Hotels.get_supplier!(supplier.id) end
    end

    test "change_supplier/1 returns a supplier changeset" do
      supplier = supplier_fixture()
      assert %Ecto.Changeset{} = Hotels.change_supplier(supplier)
    end
  end

  describe "hotel_attributes" do
    alias Hotex.Hotels.HotelAttribute

    @valid_attrs %{destination_id: "some destination_id", field: "some field", hotel_id: "some hotel_id", value: %{}}
    @update_attrs %{destination_id: "some updated destination_id", field: "some updated field", hotel_id: "some updated hotel_id", value: %{}}
    @invalid_attrs %{destination_id: nil, field: nil, hotel_id: nil, value: nil}

    def hotel_attribute_fixture(attrs \\ %{}) do
      {:ok, hotel_attribute} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Hotels.create_hotel_attribute()

      hotel_attribute
    end

    test "list_hotel_attributes/0 returns all hotel_attributes" do
      hotel_attribute = hotel_attribute_fixture()
      assert Hotels.list_hotel_attributes() == [hotel_attribute]
    end

    test "get_hotel_attribute!/1 returns the hotel_attribute with given id" do
      hotel_attribute = hotel_attribute_fixture()
      assert Hotels.get_hotel_attribute!(hotel_attribute.id) == hotel_attribute
    end

    test "create_hotel_attribute/1 with valid data creates a hotel_attribute" do
      assert {:ok, %HotelAttribute{} = hotel_attribute} = Hotels.create_hotel_attribute(@valid_attrs)
      assert hotel_attribute.destination_id == "some destination_id"
      assert hotel_attribute.field == "some field"
      assert hotel_attribute.hotel_id == "some hotel_id"
      assert hotel_attribute.value == %{}
    end

    test "create_hotel_attribute/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hotels.create_hotel_attribute(@invalid_attrs)
    end

    test "update_hotel_attribute/2 with valid data updates the hotel_attribute" do
      hotel_attribute = hotel_attribute_fixture()
      assert {:ok, %HotelAttribute{} = hotel_attribute} = Hotels.update_hotel_attribute(hotel_attribute, @update_attrs)
      assert hotel_attribute.destination_id == "some updated destination_id"
      assert hotel_attribute.field == "some updated field"
      assert hotel_attribute.hotel_id == "some updated hotel_id"
      assert hotel_attribute.value == %{}
    end

    test "update_hotel_attribute/2 with invalid data returns error changeset" do
      hotel_attribute = hotel_attribute_fixture()
      assert {:error, %Ecto.Changeset{}} = Hotels.update_hotel_attribute(hotel_attribute, @invalid_attrs)
      assert hotel_attribute == Hotels.get_hotel_attribute!(hotel_attribute.id)
    end

    test "delete_hotel_attribute/1 deletes the hotel_attribute" do
      hotel_attribute = hotel_attribute_fixture()
      assert {:ok, %HotelAttribute{}} = Hotels.delete_hotel_attribute(hotel_attribute)
      assert_raise Ecto.NoResultsError, fn -> Hotels.get_hotel_attribute!(hotel_attribute.id) end
    end

    test "change_hotel_attribute/1 returns a hotel_attribute changeset" do
      hotel_attribute = hotel_attribute_fixture()
      assert %Ecto.Changeset{} = Hotels.change_hotel_attribute(hotel_attribute)
    end
  end
end
