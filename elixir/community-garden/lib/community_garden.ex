# Use the Plot struct as it is provided
defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start() do
    Agent.start(fn -> %{registrations: [], autoid: 1} end)
  end

  def list_registrations(pid) do
    Agent.get(pid, fn state -> state.registrations end)
  end

  def register(pid, register_to) do
    Agent.get_and_update(pid, fn state ->
      plot = %Plot{plot_id: state.autoid, registered_to: register_to}
      {plot, %{registrations: [plot | state.registrations], autoid: state.autoid + 1}}
    end)
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn state ->
      %{state | registrations: Enum.reject(state.registrations, &(&1.plot_id == plot_id))}
    end)
  end

  def get_registration(pid, plot_id) do
    Agent.get(pid, fn state ->
      Enum.find(
        state.registrations,
        {:not_found, "plot is unregistered"},
        &(&1.plot_id == plot_id)
      )
    end)
  end
end
