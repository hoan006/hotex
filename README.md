# Hotex

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
