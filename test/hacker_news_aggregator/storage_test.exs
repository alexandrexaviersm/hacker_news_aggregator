defmodule HackerNewsAggregator.StorageTest do
  use ExUnit.Case

  alias HackerNewsAggregator.Storage
  alias HackerNewsAggregator.Stories.Story

  setup :start_table

  describe "save_story/2" do
    test "should sabe a story into storage" do
      story = Story.new(%{"id" => 123})
      story_index = 0

      assert Storage.save_story(story, story_index) == {:ok, story}
      assert Storage.get_story(123) == story
    end
  end

  describe "get_story/1" do
    test "should get a existing story by id" do
      story = Story.new(%{"id" => 456})
      Storage.save_story(story, _story_index = 0)

      assert Storage.get_story(456) == story
    end

    test "should returni nil if the story doesn't exist" do
      assert Storage.get_story(123) == nil
    end
  end

  describe "get_all_stories/0" do
    test "should return all stories sorted by the story_index" do
      story2 = Story.new(%{"id" => 456})
      Storage.save_story(story2, _story_index = 4)

      story1 = Story.new(%{"id" => 123})
      Storage.save_story(story1, _story_index = 0)

      story3 = Story.new(%{"id" => 789})
      Storage.save_story(story3, _story_index = 7)

      assert Storage.get_all_stories() == [story1, story2, story3]
    end
  end

  describe "get_paginated_stories/2" do
    test "should return the correct number of stories by page" do
      for id <- 0..35 do
        story = Story.new(%{"id" => id})
        Storage.save_story(story, _story_index = id)
      end

      page = 1
      stories_page_1 = Storage.get_paginated_stories(page)

      page = 4
      stories_page_4 = Storage.get_paginated_stories(page)

      assert length(stories_page_1) == 10
      assert length(stories_page_4) == 6
    end
  end

  defp start_table(_) do
    Storage.initialize()
    :ok
  end
end
