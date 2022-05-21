defmodule HackerNewsAggregatorWeb.StoriesChannelTest do
  use HackerNewsAggregatorWeb.ChannelCase

  alias HackerNewsAggregator.Storage
  alias HackerNewsAggregator.Stories.Story

  describe "client joins channel" do
    setup [:initialize_storage, :populate_storage]

    test "stories are pushed when client joins the channel" do
      {:ok, _, _socket} =
        HackerNewsAggregatorWeb.UserSocket
        |> socket()
        |> subscribe_and_join(HackerNewsAggregatorWeb.StoriesChannel, "stories:lobby")

      assert_push "top_stories", %Story{
        by: "Joe Armstrong",
        id: 123,
        score: nil,
        title: "Erlang",
        url: nil
      }

      assert_push "top_stories", %Story{
        by: "Erlang Solutions",
        id: 456,
        score: nil,
        title: "Elixir / Erlang",
        url: nil
      }
    end
  end

  defp initialize_storage(_) do
    HackerNewsAggregator.Storage.initialize()
    :ok
  end

  defp populate_storage(_) do
    story1 = %Story{id: 123, title: "Erlang", by: "Joe Armstrong"}
    story2 = %Story{id: 456, title: "Elixir / Erlang", by: "Erlang Solutions"}

    Storage.save_story(story1, _story_index = 0)
    Storage.save_story(story2, _story_index = 1)
    :ok
  end
end
