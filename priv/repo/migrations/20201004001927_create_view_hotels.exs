defmodule Hotex.Repo.Migrations.CreateViewHotels do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION tablefunc"
    execute """
    CREATE MATERIALIZED VIEW hotels AS
    SELECT c1 AS hotel_id, c2::jsonb AS amenities, c3::jsonb AS booking_conditions,
      c4 AS description, c5::integer AS destination_id, c6::jsonb AS images, c7::jsonb AS location, c8 AS name
    FROM crosstab(
      $$SELECT DISTINCT ON (k.hotel_id, k.field)
        k.hotel_id, k.field, v.value
      FROM (
        SELECT DISTINCT hotel_id, f2.field FROM hotel_attributes
        INNER JOIN
        (
          SELECT *
          FROM (values
            ('destination_id'),('name'),('location'),('description'),
            ('amenities'),('images'),('booking_conditions')
          )
          AS f1(field)
        )
        AS f2
        ON 1 = 1
      ) AS k
      LEFT JOIN hotel_attributes v
      ON k.hotel_id = v.hotel_id
      AND k.field = v.field
      ORDER BY k.hotel_id, k.field asc, v.score DESC NULLS LAST$$
    ) AS hotels(c1 text, c2 text, c3 text, c4 text, c5 text, c6 text, c7 text, c8 text)
    """
    create index(:hotels, [:hotel_id])
    create index(:hotels, [:destination_id])
  end

  def down do
    execute "DROP MATERIALIZED VIEW hotels"
    execute "DROP EXTENSION tablefunc"
  end
end
