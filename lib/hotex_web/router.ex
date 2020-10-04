defmodule HotexWeb.Router do
  use HotexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HotexWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", HotexWeb do
    pipe_through :api

    post "/hotels/add", PageController, :add_hotels
    get "/hotels/find", PageController, :find_hotels
  end

  # Other scopes may use custom stacks.
  # scope "/api", HotexWeb do
  #   pipe_through :api
  # end
end
