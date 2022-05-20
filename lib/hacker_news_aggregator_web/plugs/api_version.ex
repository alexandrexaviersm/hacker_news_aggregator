defmodule HackerNewsAggregatorWeb.ApiVersion do
  @moduledoc """
  This module is a Plug responsible to handle api versioning.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    assign(conn, :api_version, opts[:version])
  end
end
