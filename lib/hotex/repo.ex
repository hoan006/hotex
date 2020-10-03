defmodule Hotex.Repo do
  use Ecto.Repo,
    otp_app: :hotex,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok,
     Keyword.put(
       opts,
       :url,
       System.get_env("DATABASE_URL") || "postgres://postgres@localhost:5432/hotex_dev"
     )}
  end
end
