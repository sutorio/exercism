defmodule TakeANumber do
  defp loop(state \\ 0) do
    receive do
      {:report_state, caller} ->
        send(caller, state)
        loop(state)

      {:take_a_number, caller} ->
        send(caller, state + 1)
        loop(state + 1)

      :stop ->
        Process.exit(self(), :kill)

      _ ->
        loop(state)
    end
  end

  def start() do
    spawn(fn -> loop() end)
  end
end
