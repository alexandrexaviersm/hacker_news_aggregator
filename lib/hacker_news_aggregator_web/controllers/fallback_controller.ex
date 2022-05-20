defmodule HackerNewsAggregatorWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use HackerNewsAggregatorWeb, :controller

  @spec call(Plug.Conn.t(), {:error, :not_found} | {:error, :invalid_param}) :: Plug.Conn.t()
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(HackerNewsAggregatorWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :invalid_param}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(HackerNewsAggregatorWeb.StoryView)
    |> render(:invalid_param)
  end
end
