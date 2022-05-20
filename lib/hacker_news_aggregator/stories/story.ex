defmodule HackerNewsAggregator.Stories.Story do
  @moduledoc """
  The Story Schema.
  """

  @typedoc "Story"
  @type t() :: %__MODULE__{
          id: non_neg_integer | nil,
          title: String.t() | nil,
          by: String.t() | nil,
          score: integer | nil,
          url: String.t() | nil
        }

  @derive Jason.Encoder
  defstruct id: nil,
            title: nil,
            by: nil,
            score: nil,
            url: nil

  @spec new :: t()
  def new, do: %__MODULE__{}

  @spec new(map) :: t()
  def new(param) when is_map(param) do
    story_with_atom_keys =
      for {key, val} <- param, into: %{} do
        {String.to_atom(key), val}
      end

    struct(__MODULE__, story_with_atom_keys)
  end
end
