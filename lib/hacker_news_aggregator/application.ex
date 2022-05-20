defmodule HackerNewsAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    initialize_ets_table(hacker_news_aggregator_env())

    children = [
      # Start the Telemetry supervisor
      HackerNewsAggregatorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HackerNewsAggregator.PubSub},
      # Start the Endpoint (http/https)
      HackerNewsAggregatorWeb.Endpoint,
      {Task.Supervisor, name: HackerNewsAggregator.TaskSupervisor}
    ]

    children = children ++ worker_by_env(hacker_news_aggregator_env())

    opts = [strategy: :one_for_one, name: HackerNewsAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp initialize_ets_table(:test), do: nil
  defp initialize_ets_table(_), do: HackerNewsAggregator.Storage.initialize()

  defp worker_by_env(:test), do: []
  defp worker_by_env(_), do: [HackerNewsAggregator.Server]

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HackerNewsAggregatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp hacker_news_aggregator_env do
    Application.get_env(:hacker_news_aggregator, :env)
  end
end
