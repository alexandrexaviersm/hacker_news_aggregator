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
      assert {:ok, _pid} = start_supervised({Server, []})
    end
  end

  describe "poll_hacker_news_api" do
    test "when the process starts, the HackerNewsApi interface is called for every 50 stories" do
      test_pid = self()
      ref = make_ref()

      expect(ApiBehaviourMock, :fetch_500_top_stories_ids, 1, fn ->
        send(test_pid, {:fetch_500_top_stories_ids_called, ref})
        {:ok, 1..500}
      end)

      # expect this function to be called 50 times (each one of the 50 stories would call once)
      expect(ApiBehaviourMock, :fetch_story, 50, fn _story_id ->
        send(test_pid, {:fetch_story_called, ref})
        {:ok, %{"id" => 123}}
      end)

      start_supervised!({Server, []})

      # assertion that func :fetch_500_top_stories_ids was called only once
      assert_receive {:fetch_500_top_stories_ids_called, ^ref}
      refute_receive {:fetch_500_top_stories_ids_called, ^ref}

      # assertion that func :fetch_story was called exactly 50 times
      for _ <- 1..50 do
        assert_receive {:fetch_story_called, ^ref}
      end

      refute_receive {:fetch_story_called, ^ref}

      # checks if all 50 stories have been saved to storage
      assert HackerNewsAggregator.Storage.get_all_stories() |> length() == 50
    end

    test "should retry the failed requests" do
      test_pid = self()
      ref = make_ref()

      # returns error for the first 20 stories
      expect(ApiBehaviourMock, :fetch_story, 20, fn _story_id ->
        send(test_pid, {:fetch_story_called, ref})
        {:error, :http_request_failed}
      end)

      # expects 50 calls - the first 20 requests will be executed again + 30 remaining
      expect(ApiBehaviourMock, :fetch_story, 50, fn _story_id ->
        send(test_pid, {:fetch_story_called, ref})
        {:ok, %{"id" => 123}}
      end)

      start_supervised!({Server, []})

      # assertion that func :fetch_story was called exactly 70 times
      # as the first 20 failed, so they had to be reprocessed
      for _ <- 1..70 do
        assert_receive {:fetch_story_called, ^ref}
      end

      refute_receive {:fetch_story_called, ^ref}

      assert HackerNewsAggregator.Storage.get_all_stories() |> length() == 50
    end
  end
end
