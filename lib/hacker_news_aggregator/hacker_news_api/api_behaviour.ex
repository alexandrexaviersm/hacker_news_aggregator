defmodule HackerNewsAggregator.HackerNewsApi.ApiBehaviour do
  @moduledoc """
  Hacker News API Interface
  """

  @type story_id :: non_neg_integer
  @type story_data :: %{
          by: String.t(),
          descendants: integer,
          id: integer,
          kids: list,
          score: integer,
          time: integer,
          title: String.t(),
          type: String.t(),
          url: String.t()
        }

  @callback fetch_500_top_stories_ids :: {:ok, list(story_id)} | {:error, :http_request_failed}
  @callback fetch_story(story_id) ::
              {:ok, story_data} | {:error, :http_request_failed | :story_not_found}
end
