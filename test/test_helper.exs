Application.ensure_all_started(:mox)
Mox.defmock(HttpAdapterMock, for: HackerNewsAggregator.HackerNewsApi.HttpAdapterBehaviour)
Mox.defmock(ApiBehaviourMock, for: HackerNewsAggregator.HackerNewsApi.ApiBehaviour)

ExUnit.start()
