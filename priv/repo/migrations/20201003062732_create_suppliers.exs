defmodule Hotex.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :name, :text
      add :parser_code, :text
      add :sample_input, :text

      timestamps(default: fragment("NOW()"))
    end
  end
end
