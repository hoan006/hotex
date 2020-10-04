# About the app: Hotex

To install Elixir:

  * With brew: `brew install elixir`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup` (1)
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Note

- (1) This is assuming you have a running Postgres instance on your localhost with username as `postgres` and no password. If you wish to use another database, append DATABASE_URL before running each mix command, such as

```
DATABASE_URL=postgres://user:pass@localhost:5432/fun_db mix ecto.setup
```

# Deployment

The app can be released in production mode via a Docker image. Please look at Dockerfile to see what it requires.

To run the app in production mode on localhost with Docker installed, follow these following steps:

- Update docker-compose.yml to your liking
- Manually create database on your Postgres instance matching DATABASE_URL docker-compose.yml. Docker run does not cover database creation.
- Run `docker-compose up`

To run the app on hosted Docker cloud service, such as Amazon ECS, push the Docker image to the cloud, and use their API to register corresponding resources.

# Technical Design

The web app contains two main functions

## Procuring the data

- Each supplier information is persisted on database (as `suppliers`). They may have their own parser implementation via `parse_code`. With sample data, let's name them as `red`, `blue` and `green`.
- Each parser will collect information from the HTTP response output on each attribute: `name`, `description`, `location`, `amenities`, `image` and `booking_conditions`. There attributes will trim text content if possible, and exclude ones without values.
- Those attributes above are persisted on database (as `hotel_attributes`), one row per attribute. For example, if one hotel from supplier `red` only have data on `name`, `location` then 2 rows will be inserted.
- Attribute row has `field` column to record attribute name (`destination_id` is also one of them), and `value` column (as text) to record attribute value. Depending on the `field` name, its `value` will be converted properly (number, text, jsonb) during delivery phase.
- Attribute row also has `score` column to record to determine which attribute row to pick when querying hotel data. Each attribute name has different scoring method, which can be refined in future.
- Attribute rows are bulk inserted with `on conflict` mode instead of `find-and-replace` approach - achieving huge performance gain. This also enables procuring the data in concurrent processes without concerning of stale data.
- Finally, hotel attributes are merged into `hotels` table, only highest `score` attribute values (aka best data) are used. The implementation will be mentioned in merging technique section below.
- Procuring the data can happen in one single database query.

## Delivering the data

- `hotels` have the same data structure with the requirement expected response. Users can filter hotels by Hotel IDs or Destination ID with ease. For example

(http://localhost:4000/api/hotels/find?hotel_id=iJhz%2CSjyX&destination_id=5432&q=)[http://localhost:4000/api/hotels/find?hotel_id=iJhz%2CSjyX&destination_id=5432&q=]

- The web app also support `ilike` text search accross all fields with **an advanced feature**: It also search for non-best data. If non-best data are found while the best ones do not include the search text, the app will use non-best data in the response.

For example, hotel `iJhz` is using the best description which comes from supplier `blue`:

```
{
    "hotel_id": "iJhz"
    ...,
    "description": "Surrounded by tropical gardens, these upscale villas in elegant Colonial-style buildings are part of the Resorts World Sentosa complex and a 2-minute walk from the Waterfront train station. Featuring sundecks and pool, garden or sea views, the plush 1- to 3-bedroom villas offer free Wi-Fi and flat-screens, as well as free-standing baths, minibars, and tea and coffeemaking facilities. Upgraded villas add private pools, fridges and microwaves; some have wine cellars. A 4-bedroom unit offers a kitchen and a living room. There's 24-hour room and butler service. Amenities include posh restaurant, plus an outdoor pool, a hot tub, and free parking.",
    ...
}
```

But if user searches for `5 star hotel`, web app will use description from supplier `red` instead

(http://localhost:4000/api/hotels/find?hotel_id=iJhz%2CSjyX&destination_id=5432&q=5+star+hotel)[http://localhost:4000/api/hotels/find?hotel_id=iJhz%2CSjyX&destination_id=5432&q=5+star+hotel]

```
{
    "hotel_id": "iJhz"
    ...,
    "description": "This 5 star hotel is located on the coastline of Singapore.",
    ...
}
```

- Delivering the data happens in one single database query.

## Merging technique

Disclaimer: This is the part where I've found most interesting. My self-challenge is how to keep **all** of hotel attributes from suppliers while still being able to delivery the data efficiently.

The detail can be found in the file `20201004001927_create_view_hotels.exs`. Here is the lengthy explanation

- Step 1: Create a table matrix between all `hotel_id`s and all attribute names. That explains the quirk `ON 1=1` part.
- Step 2: Build a SELECT query with 3 rows `(hotel_id, field, value)`. For each hotel, the query should return exact 7 rows (6 attributes + `destination_id`) order by `field`.
- Step 3: Transpose data from rows to columns with Postgres extension function: `crosstab`. This returns a table with 8 columns: `hotel_id` and 7 columns for 7 attributes above.
- Step 4: Convert each column to its corresponding data type: number, text, or jsonb, then cache the response with Postgres `MATERIALZIED VIEW`
- Step 5: Add indexes for faster query.

Now we have the virtual `hotels` table, which can be used to deliver the data. This approach has the advantage of optimizing the procuring phase, but the tradeoff is that this `hotels` table need to be refreshed to have the latest procuring data. For the purpose of this demo, `hotels` are refreshed when user adds more data from supplier(s). In production environment, refreshing `hotels` should only run periodically (e.g. once per hour) instead.

Another advantage of this method is, if the scoring methods change, we can simply re-run the score calculation on one table (`hotel_attributes`) instead of re-pulling all hotel data from the Internet.
