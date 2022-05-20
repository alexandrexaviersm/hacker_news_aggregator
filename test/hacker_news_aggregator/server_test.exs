defmodule HackerNewsAggregator.ServerTest do
  use ExUnit.Case

  alias HackerNewsAggregator.Server

  import Mox

  setup :set_mox_from_context
  setup :verify_on_exit!

  setup do
    HackerNewsAggregator.Storage.initialize()

    stub_with(ApiBehaviourMock, HackerNewsAggregator.HackerNewsApiStub)
    :ok
  end

  describe "start_link/1" do
    test "start the gen_server" do
      assert {:ok, _pid} = Server.start_link([])
    end
  end

  describe "poll_hacker_news_api" do
    test "should pull 50 stories and saves into the Storage" do
      Server.start_link([])

      # READ
      # Using `Process.sleep()` here is not pragmatic but I didn't have time to improve the Server and make it more testable

      # A better alternative would be to make the assertions with the function assert_receive {:save_story_called, ^ref}
      # so this process would get a message :save_story_called for every saved story and we wouldn't need to use Process.sleep

      # Also, this proposed approach would help to test retries when the API returns error
      Process.sleep(500)

      assert HackerNewsAggregator.Storage.get_all_stories() |> length() == 50
    end
  end
end
