defmodule Hotex.Repo.Migrations.InsertSupplierRows do
  use Ecto.Migration

  def up do
    execute """
      INSERT INTO suppliers(name, parser_code, sample_input) VALUES
        ('Supplier Red', 'red', 'http://www.mocky.io/v2/5ebbea002e000054009f3ffc'),
        ('Supplier Blue', 'blue', 'http://www.mocky.io/v2/5ebbea102e000029009f3fff'),
        ('Supplier Green', 'green', 'http://www.mocky.io/v2/5ebbea1f2e00002b009f4000')
    """
  end

  def down do
    execute """
      DELETE FROM suppliers
    """
  end
end
