defmodule HackerNewsAggregator.HackerNewsApi.HttpAdapterBehaviour do
  @moduledoc """
  Http Adapter Interface
  """
  @type result :: {status_line, headers, body}
  @type status_line :: {http_version, status_code, reason_phrase}

  @type http_version :: charlist
  @type status_code :: integer
  @type reason_phrase :: charlist

  @type headers :: list(header)
  @type header :: {field :: charlist, value :: charlist}

  @type body :: charlist

  @type reason :: charlist

  @type url :: String.t()

  @callback request(url) :: {:ok, result} | {:error, reason}
end
