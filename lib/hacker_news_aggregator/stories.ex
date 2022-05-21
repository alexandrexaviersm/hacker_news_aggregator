defmodule HackerNewsAggregator.Stories do
  @moduledoc """
  The Stories context.
  """

  alias HackerNewsAggregator.Storage
  alias HackerNewsAggregator.Stories.Story

  @typedoc """
  Story position taken from Hacker News API
  """
  @type story_index :: non_neg_integer

  @typedoc """
  Story ID from Hacker News API
  """
  @type story_id :: non_neg_integer

  @doc """
  Returns all 50 top stories IDS from Hacker News API

  ## Examples
      iex> HackerNewsAggregator.Stories.fetch_and_filter_top_stories_ids_from_hacker_news()
      {:ok, [123, 456, 789]}

      iex> HackerNewsAggregator.Stories.fetch_and_filter_top_stories_ids_from_hacker_news()
      {:error, :http_request_failed}
  """
  @spec fetch_and_filter_top_stories_ids_from_hacker_news ::
          {:ok, list(story_id)} | {:error, :http_request_failed}
  def fetch_and_filter_top_stories_ids_from_hacker_news do
    with {:ok, story_ids} <- hacker_news_api().fetch_500_top_stories_ids() do
      {:ok, Enum.take(story_ids, 50)}
    end
  end

  @doc """
  Returns a story by its ID from Hacker News API

  ## Examples

      iex(1)> story_id = 123
      123
      iex(2)> HackerNewsAggregator.Stories.fetch_story_by_story_id_from_hacker_news(story_id)
      {:ok,
      %HackerNewsAggregator.Stories.Story{
        by: "Joe Armstrong",
        id: 123,
        score: nil,
        title: "Erlang",
        url: nil
      }}
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
  Saves the story to storage and broadcasts it to all clients connected to the channel

  ## Examples

      iex(1)> story = %HackerNewsAggregator.Stories.Story{id: 123, by: "Joe Armstrong", title: "Erlang"}
      %HackerNewsAggregator.Stories.Story{
        by: "Joe Armstrong",
        id: 123,
        score: nil,
        title: "Erlang",
        url: nil
      }
      iex(2)> story_index = 0
      0
      iex(3)> HackerNewsAggregator.Stories.process_story_into_aggregator(story, story_index)
      {:ok, :operation_completed}
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
  Returns a list of stories (10 results per page)

  ## Examples

      iex(1)> page = 3
      3
      iex(2)> HackerNewsAggregator.Stories.get_stories_from_storage(page)
      {:ok,
      [
        %HackerNewsAggregator.Stories.Story{
          by: "Joe Armstrong",
          id: 123,
          score: nil,
          title: "Erlang",
          url: nil
        }
      ]}
  """
  @spec get_stories_from_storage(page :: non_neg_integer) :: {:ok, list(Story.t())} | []
  def get_stories_from_storage(page) when is_integer(page) do
    {:ok, Storage.get_paginated_stories(page)}
  end

  @doc """
  Returns all 50 stories from the storage

  ## Examples

      iex> HackerNewsAggregator.Stories.get_all_stories_from_storage()
      [
        %HackerNewsAggregator.Stories.Story{
          by: "Joe Armstrong",
          id: 123,
          score: nil,
          title: "Erlang",
          url: nil
        }
      ]
  """
  @spec get_all_stories_from_storage :: list(Story.t())
  def get_all_stories_from_storage do
    Storage.get_all_stories()
  end

  @doc """
  Returns the story struct by id from the Storage

  ## Examples

      iex(1)> story_id = 123
      123
      iex(2)> HackerNewsAggregator.Stories.get_story_from_storage(story_id)
      {:ok,
      %HackerNewsAggregator.Stories.Story{
        by: "Joe Armstrong",
        id: 123,
        score: nil,
        title: "Erlang",
        url: nil
      }}
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
