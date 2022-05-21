defmodule HackerNewsAggregatorWeb.StoriesChannel do
  @moduledoc false
  use HackerNewsAggregatorWeb, :channel

  alias HackerNewsAggregator.Stories

  @impl true
  def join("stories:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    Stories.get_all_stories_from_storage()
    |> Enum.each(&push(socket, "top_stories", &1))

    {:noreply, socket}
  end
end
