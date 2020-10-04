defmodule Hotex.Repo.Migrations.CreateHotelAttributes do
  use Ecto.Migration

  def change do
    create table(:hotel_attributes) do
      add :hotel_id, :text
      add :field, :text
      add :value, :text
      add :score, :integer, default: 0
      add :supplier_id, references(:suppliers, on_delete: :nothing)

      timestamps(default: fragment("NOW()"))
    end

    create index(:hotel_attributes, [:supplier_id])
    create unique_index(:hotel_attributes, [:hotel_id, :supplier_id, :field])
    create index(:hotel_attributes, [:value])
  end
end
