defmodule HackerNewsAggregator.HackerNewsApiStub do
  @moduledoc false

  @behaviour HackerNewsAggregator.HackerNewsApi.ApiBehaviour

  @type story_id :: non_neg_integer

  @impl true
  def fetch_500_top_stories_ids do
    {:ok, Enum.to_list(1..500)}
  end

  @impl true
  def fetch_story(story_id) do
    {:ok,
     %{
       "by" => "foo #{story_id}",
       "descendants" => 1,
       "id" => story_id,
       "kids" => [],
       "score" => 2,
       "time" => 123,
       "title" => "foo title #{story_id}",
       "type" => "story",
       "url" => "www.foobar.com"
     }}
  end
end
