defmodule HackerNewsAggregator.HackerNewsApi do
  @moduledoc """
  Hacker News API
  """
  @behaviour HackerNewsAggregator.HackerNewsApi.ApiBehaviour

  require Logger

  alias HackerNewsAggregator.HackerNewsApi.ApiBehaviour

  @impl true
  @doc """
  Fetch 500 top stories ids from hacker news api
  """
  @spec fetch_500_top_stories_ids :: {:ok, list(non_neg_integer)} | {:error, :http_request_failed}
  def fetch_500_top_stories_ids do
    top_stories_api_url()
    |> http_adapter().request()
    |> handle_response()
  end

  @impl true
  @doc """
  Fetch a single story by the story_id from hacker news api
  """
  @spec fetch_story(story_id :: non_neg_integer) ::
          {:ok, ApiBehaviour.story_data()} | {:error, :http_request_failed | :story_not_found}
  def fetch_story(story_id) do
    fetch_item_api_url(story_id)
    |> http_adapter().request()
    |> handle_response()
    |> case do
      {:ok, nil} -> {:error, :story_not_found}
      {:ok, story} -> {:ok, story}
    end
  end

  defp handle_response({:ok, {{_, 200, _}, _headers, body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:error, reason}) do
    Logger.warn("HTTP Request failed. Reason #{inspect(reason)}")

    {:error, :http_request_failed}
  end

  defp http_adapter do
    Application.get_env(:hacker_news_aggregator, :hacker_news_api)[:http_adapter]
  end

  defp top_stories_api_url do
    base_url()
    |> Path.join(version())
    |> Path.join("topstories.json")
  end

  defp fetch_item_api_url(story_id) do
    base_url()
    |> Path.join(version())
    |> Path.join("item/#{story_id}.json")
  end

  defp base_url, do: Application.fetch_env!(:hacker_news_aggregator, :hacker_news_api)[:base_url]
  defp version, do: Application.fetch_env!(:hacker_news_aggregator, :hacker_news_api)[:version]
end
