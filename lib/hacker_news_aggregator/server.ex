defmodule HackerNewsAggregator.Server do
  @moduledoc """
  GenServer responsible for the recurring task of fetching the Hacker News API.

  Every 5 minutes, an HTTP request is made on the HackerNews API that returns the IDS of the top 50 stories.

  After that we make an HTTP request for each Story ID returned (to get more details from each story)
  To achieve this, we create 50 new distinct processes that will concurrently fetch the HackerNews API.
  """
  use GenServer

  require Logger

  alias HackerNewsAggregator.Stories

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init([]) :: {:ok, %{tasks: %{}}}
  def init([]) do
    schedule_hacker_news_api_poll()

    send(self(), :poll_hacker_news_api)

    {:ok, %{tasks: %{}}}
  end

  def handle_info(:poll_hacker_news_api, state) do
    case Stories.fetch_and_filter_top_stories_ids_from_hacker_news() do
      {:ok, story_ids} ->
        state =
          Enum.with_index(story_ids, fn story_id, story_index ->
            task = create_task_to_fetch_story_from_hacker_news(story_id, story_index)
            {task.ref, story_id, story_index}
          end)
          |> Enum.reduce(state, fn {task_ref, story_id, story_index}, state_acc ->
            put_in(state_acc.tasks[task_ref], {story_id, story_index})
          end)

        {:noreply, state}

      {:error, :http_request_failed} ->
        # HTTP request failed. Retry after 1 sec (a retry logic with an Exponential backoff would be a better approach)
        Process.send_after(self(), :poll_hacker_news_api, 1_000)

        {:noreply, state}
    end
  end

  # The task completed successfully
  def handle_info({ref, {:ok, :operation_completed} = _result}, state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])

    {{_story_id, _story_index}, updated_state} = pop_in(state.tasks[ref])

    {:noreply, updated_state}
  end

  # The task completed with error
  def handle_info({ref, {:error, _any_reason} = _result}, state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])

    # creates another task to retry the operation
    updated_state = retry_task_to_fetch_story_from_hacker_news(state, ref)

    {:noreply, updated_state}
  end

  # The task crashed
  def handle_info({:DOWN, ref, _, _pid, _reason}, state) do
    # creates another task to retry the operation
    updated_state = retry_task_to_fetch_story_from_hacker_news(state, ref)

    {:noreply, updated_state}
  end

  defp create_task_to_fetch_story_from_hacker_news(story_id, story_index) do
    Task.Supervisor.async_nolink(HackerNewsAggregator.TaskSupervisor, fn ->
      with {:ok, story} <- Stories.fetch_story_by_story_id_from_hacker_news(story_id) do
        Stories.process_story_into_aggregator(story, story_index)
      end
    end)
  end

  defp retry_task_to_fetch_story_from_hacker_news(state, task_ref) do
    {{story_id, story_index}, updated_state} = pop_in(state.tasks[task_ref])

    Logger.warn("Task to fetch story #{inspect(story_id)} from_hacker_news failed")

    Logger.warn("Retriyng task to fetch story: #{inspect(story_id)}")

    task = create_task_to_fetch_story_from_hacker_news(story_id, story_index)

    put_in(updated_state.tasks[task.ref], {story_id, story_index})
  end

  defp schedule_hacker_news_api_poll do
    :timer.send_interval(:timer.minutes(5), :poll_hacker_news_api)
  end
end
