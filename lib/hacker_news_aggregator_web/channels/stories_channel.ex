defmodule HackerNewsAggregatorWeb.StoriesChannel do
  @moduledoc false
  use HackerNewsAggregatorWeb, :channel

  alias HackerNewsAggregator.Stories

  @impl true
  def join("stories:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    Stories.get_all_stories_from_storage()
    |> Enum.each(&push(socket, "top_stories", &1))

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
