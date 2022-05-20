defmodule HackerNewsAggregator.HackerNewsApiTest do
  use ExUnit.Case
  alias HackerNewsAggregator.HackerNewsApi

  import Mox

  setup :verify_on_exit!

  describe "fetch_500_top_stories_ids/0" do
    test "should return an {:ok, result} tuple for a succefull http request" do
      expect(HttpAdapterMock, :request, fn url ->
        assert url == "https://hacker-news.firebaseio.com/v0/topstories.json"
        result = Jason.encode!([123, 456, 789])
        {:ok, {{'http_version', 200, 'reason_phrase'}, [], result}}
      end)

      assert HackerNewsApi.fetch_500_top_stories_ids() == {:ok, [123, 456, 789]}
    end

    test "should return an {:error, :http_request_failed} tuple if the http request fails" do
      expect(HttpAdapterMock, :request, fn url ->
        assert url == "https://hacker-news.firebaseio.com/v0/topstories.json"
        {:error, 'reason'}
      end)

      assert HackerNewsApi.fetch_500_top_stories_ids() == {:error, :http_request_failed}
    end
  end

  describe "fetch_story/1" do
    test "a" do
      expect(HttpAdapterMock, :request, fn url ->
        assert url == "https://hacker-news.firebaseio.com/v0/item/123.json"
        story = Jason.encode!(%{id: 123, by: "Joe Doe", title: "foo title"})
        {:ok, {{'http_version', 200, 'reason_phrase'}, [], story}}
      end)

      story_id = 123

      assert HackerNewsApi.fetch_story(story_id) ==
               {:ok, %{"id" => 123, "by" => "Joe Doe", "title" => "foo title"}}
    end
  end
end
