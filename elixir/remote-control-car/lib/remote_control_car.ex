defmodule RemoteControlCar do
  @enforce_keys [:nickname]
  defstruct [:nickname, battery_percentage: 100, distance_driven_in_meters: 0]

  @spec new(String.t()) :: %RemoteControlCar{}
  def new(nickname \\ "none"), do: %RemoteControlCar{nickname: nickname}

  @spec display_distance(%RemoteControlCar{}) :: String.t()
  def display_distance(remote_car) when is_struct(remote_car, RemoteControlCar) do
    "#{remote_car.distance_driven_in_meters} meters"
  end

  @spec display_distance(%RemoteControlCar{}) :: String.t()
  def display_battery(remote_car) when is_struct(remote_car, RemoteControlCar) do
    case remote_car.battery_percentage do
      0 -> "Battery empty"
      percentage -> "Battery at #{percentage}%"
    end
  end

  def drive(remote_car) when is_struct(remote_car, RemoteControlCar) do
    case {remote_car.battery_percentage, remote_car.distance_driven_in_meters} do
      {0, _} ->
        remote_car

      {battery, distance} ->
        %{remote_car | battery_percentage: battery - 1, distance_driven_in_meters: distance + 20}
    end
  end
end
