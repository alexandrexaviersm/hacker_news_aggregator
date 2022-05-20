defmodule HackerNewsAggregator.Stories do
  @moduledoc """
  The Stories context.
  """

  alias HackerNewsAggregator.Storage
  alias HackerNewsAggregator.Stories.Story

  @type story_index :: non_neg_integer
  @type story_id :: non_neg_integer

  @doc """

  """
  @spec fetch_and_filter_top_stories_ids_from_hacker_news ::
          {:ok, list(story_id)} | {:error, :http_request_failed}
  def fetch_and_filter_top_stories_ids_from_hacker_news do
    with {:ok, story_ids} <- hacker_news_api().fetch_500_top_stories_ids() do
      {:ok, Enum.take(story_ids, 50)}
    end
  end

  @doc """

  """
  @spec fetch_story_by_story_id_from_hacker_news(story_id) ::
          {:ok, Story.t()} | {:error, :http_request_failed | :story_not_found}
  def fetch_story_by_story_id_from_hacker_news(story_id) do
    with {:ok, hacker_news_story_data} <- hacker_news_api().fetch_story(story_id),
         %Story{} = story <- Story.new(hacker_news_story_data) do
      {:ok, story}
    end
  end

  @doc """

  """
  @spec process_story_into_aggregator(Story.t(), non_neg_integer) ::
          {:error, :failed_operation} | {:ok, :operation_completed}
  def process_story_into_aggregator(%Story{} = story, story_index) do
    Storage.save_story(story, story_index)
    |> broadcast_new_story()
    |> case do
      :ok -> {:ok, :operation_completed}
      _ -> {:error, :failed_operation}
    end
  end

  @doc """

  """
  @spec get_stories_from_storage(page :: non_neg_integer) :: {:ok, list(Story.t())} | []
  def get_stories_from_storage(page) when is_integer(page) do
    {:ok, Storage.get_paginated_stories(page)}
  end

  @doc """

  """
  @spec get_all_stories_from_storage :: list(Story.t())
  def get_all_stories_from_storage do
    Storage.get_all_stories()
  end

  @doc """

  """
  @spec get_story_from_storage(story_id) :: {:ok, Story.t()} | {:error, :not_found}
  def get_story_from_storage(story_id) when is_integer(story_id) do
    case Storage.get_story(story_id) do
      %Story{} = story -> {:ok, story}
      nil -> {:error, :not_found}
    end
  end

  defp hacker_news_api do
    Application.get_env(:hacker_news_aggregator, :hacker_news_api)[:api_client]
  end

  defp broadcast_new_story({:ok, story}) do
    HackerNewsAggregatorWeb.Endpoint.broadcast("stories:lobby", "new_story", story)
  end
end
