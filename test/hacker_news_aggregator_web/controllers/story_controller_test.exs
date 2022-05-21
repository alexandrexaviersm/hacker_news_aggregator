defmodule HackerNewsAggregatorWeb.StoryControllerTest do
  use HackerNewsAggregatorWeb.ConnCase

  alias HackerNewsAggregator.Storage
  alias HackerNewsAggregator.Stories.Story

  setup :initialize_storage

  describe "top_stories" do
    test "should display an empty list of data", %{conn: conn} do
      conn = get(conn, Routes.story_path(conn, :top_stories))
      assert Enum.empty?(json_response(conn, 200)["data"])

      assert json_response(conn, 200) == %{"data" => []}
    end

    test "lists 50 top stories", %{conn: conn} do
      populate_storage([])

      conn = get(conn, Routes.story_path(conn, :top_stories))
      refute Enum.empty?(json_response(conn, 200)["data"])

      assert json_response(conn, 200)["data"] == [
               %{
                 "by" => "John Doe",
                 "id" => 123,
                 "score" => nil,
                 "title" => "foo title",
                 "url" => nil
               },
               %{
                 "by" => "Erlang Solutions",
                 "id" => 456,
                 "score" => nil,
                 "title" => "bar title",
                 "url" => nil
               }
             ]
    end
  end

  describe "get_story" do
    test "should return 404 for a story_id that doesn't exists", %{conn: conn} do
      story_id = "123"
      conn = get(conn, Routes.story_path(conn, :get_story, story_id))

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end

    test "show the story", %{conn: conn} do
      populate_storage([])
      story_id = "123"

      conn = get(conn, Routes.story_path(conn, :get_story, story_id))

      assert %{
               "data" => %{
                 "by" => "John Doe",
                 "id" => 123,
                 "score" => nil,
                 "title" => "foo title",
                 "url" => nil
               }
             } = json_response(conn, 200)
    end

    test "should return 422 for ", %{conn: conn} do
      story_id = "invalid_id"
      conn = get(conn, Routes.story_path(conn, :get_story, story_id))

      assert %{
               "errors" => %{
                 "detail" =>
                   "That given parameter number seems to be invalid, please try using a valid Integer for the params number."
               }
             } = json_response(conn, 422)
    end
  end

  defp initialize_storage(_) do
    Storage.initialize()
    :ok
  end

  defp populate_storage(_) do
    story1 = %Story{id: 123, title: "foo title", by: "John Doe"}
    story2 = %Story{id: 456, title: "bar title", by: "Erlang Solutions"}

    Storage.save_story(story1, _story_index = 0)
    Storage.save_story(story2, _story_index = 1)

    :ok
  end
end
