defmodule HighScore do
  def new(), do: %{}

  def add_player(scores, name), do: add_player(scores, name, 0)
  def add_player(scores, name, score), do: Map.put(scores, name, score)

  def remove_player(scores, name), do: Map.delete(scores, name)

  def reset_score(scores, name), do: Map.update(scores, name, 0, fn _ -> 0 end)

  def update_score(scores, name, score), do: Map.update(scores, name, score, &(&1 + score))

  def get_players(scores), do: Map.keys(scores)
end
