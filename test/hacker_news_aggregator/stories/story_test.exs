defmodule HackerNewsAggregator.Stories.StoryTest do
  use ExUnit.Case, async: true

  alias HackerNewsAggregator.Stories.Story

  describe "new/0" do
    test "should create a empty story struct" do
      assert Story.new() == %Story{
               by: nil,
               id: nil,
               score: nil,
               title: nil,
               url: nil
             }
    end
  end

  describe "new/1" do
    test "should create a story struct with the correct params" do
      story_param = %{
        "id" => 123,
        "title" => "Story title",
        "by" => "Joe",
        "score" => 456,
        "url" => "hackernews.com"
      }

      assert Story.new(story_param) == %Story{
               id: 123,
               title: "Story title",
               by: "Joe",
               url: "hackernews.com",
               score: 456
             }
    end
  end
end
