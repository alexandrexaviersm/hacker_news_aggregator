defmodule HackerNewsAggregator.Storage do
  @moduledoc """
  Storage powered by Erlang Term Storage(ETS)
  """

  import Ex2ms

  alias HackerNewsAggregator.Stories.Story

  @type story_id :: non_neg_integer
  @type story_index :: non_neg_integer

  @spec initialize :: atom | :ets.tid()
  def initialize do
    :ets.new(:top_stories_table, [:named_table, :public, read_concurrency: true])
  end

  @doc """
  Save the stories in the following structure:
    {story_index, story_id, story_struct}
  """
  @spec save_story(Story.t(), story_index) :: {:ok, Story.t()}
  def save_story(%Story{} = story, story_index) do
    with true <- :ets.insert(:top_stories_table, {story_index, story.id, story}) do
      {:ok, story}
    end
  end

  @doc """
  Gets a single story by its id
  """
  @spec get_story(story_id) :: Story.t() | nil
  def get_story(story_id) do
    :ets.match_object(:top_stories_table, {:_, story_id, :_})
    |> List.first()
    |> case do
      {_story_index, _story_id, story} -> story
      _ -> nil
    end
  end

  @doc """
  Gets all 50 top stories in the same order as the Hacker News API
  """
  @spec get_all_stories :: list(Story.t())
  def get_all_stories do
    :ets.tab2list(:top_stories_table)
    |> order_stories_by_index()
  end

  @doc """
  Gets paginated stories by the page number.
  Default 10 per page.
  """
  @spec get_paginated_stories(page :: non_neg_integer, per_page :: non_neg_integer) ::
          list(Story.t())
  def get_paginated_stories(page, per_page \\ 10) do
    offset = (page - 1) * per_page
    limit = offset + per_page

    :ets.select(:top_stories_table, mount_query_params(offset, limit))
    |> order_stories_by_index()
  end

  defp order_stories_by_index(stories) do
    stories
    |> Enum.sort_by(fn {story_index, _story_id, _story} -> story_index end)
    |> Enum.map(fn {_story_index, _story_id, story} -> story end)
  end

  defp mount_query_params(offset, limit) do
    fun do
      {index, _story_id, story} = row when index >= ^offset and index < ^limit -> row
    end
  end
end
