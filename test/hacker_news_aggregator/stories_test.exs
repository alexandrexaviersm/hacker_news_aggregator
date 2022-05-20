defmodule HackerNewsAggregator.StoriesTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  alias HackerNewsAggregator.Stories
  alias HackerNewsAggregator.Stories.Story

  setup do
    HackerNewsAggregator.Storage.initialize()
    :ok
  end

  describe "fetch_and_filter_top_stories_ids_from_hacker_news/0" do
    test "should only return 50 stories out of 500 from HackerNews API" do
      expect(ApiBehaviourMock, :fetch_500_top_stories_ids, fn ->
        {:ok, 1..500}
      end)

      assert {:ok, top_50_stories} = Stories.fetch_and_filter_top_stories_ids_from_hacker_news()

      assert length(top_50_stories) == 50
    end
  end

  describe "fetch_story_by_story_id_from_hacker_news/1" do
    test "should return a story struct" do
      expect(ApiBehaviourMock, :fetch_story, fn story_id ->
        assert story_id == 123
        {:ok, %{"id" => 123}}
      end)

      story_id = 123
      assert {:ok, %Story{id: 123}} = Stories.fetch_story_by_story_id_from_hacker_news(story_id)
    end

    test "should return an error tuple if the get request don't find the data" do
      expect(ApiBehaviourMock, :fetch_story, fn story_id ->
        assert story_id == 123
        {:error, :story_not_found}
      end)

      assert {:error, :story_not_found} = Stories.fetch_story_by_story_id_from_hacker_news(123)
    end
  end

  describe "process_story_into_aggregator/2" do
    test "process story into aggregator" do
      story = %Story{id: 123}
      story_index = 0

      assert Stories.process_story_into_aggregator(story, story_index) ==
               {:ok, :operation_completed}
    end
  end

  describe "get_story_from_storage/1" do
    test "get an existing story from the storage by id" do
      story = Story.new(%{"id" => 123})
      Stories.process_story_into_aggregator(story, _story_index = 0)

      story_id = 123
      assert {:ok, ^story} = Stories.get_story_from_storage(story_id)
    end

    test "should return not_found for a story_id that is not present in the storage" do
      story_id = 123
      assert Stories.get_story_from_storage(story_id) == {:error, :not_found}
    end
  end
end
