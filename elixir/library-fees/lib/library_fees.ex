defmodule LibraryFees do
  @spec datetime_from_string(String.t()) :: %NaiveDateTime{}
  def datetime_from_string(string) do
    NaiveDateTime.from_iso8601!(string)
  end

  @spec before_noon?(%NaiveDateTime{}) :: boolean()
  def before_noon?(datetime) do
    datetime
    |> NaiveDateTime.to_time()
    |> Time.before?(~T[12:00:00])
  end

  @spec return_date(%NaiveDateTime{}) :: %Date{}
  def return_date(checkout_datetime) do
    days = if before_noon?(checkout_datetime), do: 28, else: 29

    checkout_datetime
    |> NaiveDateTime.add(days, :day)
    |> NaiveDateTime.to_date()
  end

  @spec days_late(%Date{}, %NaiveDateTime{}) :: integer()
  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> NaiveDateTime.to_date()
    |> Date.diff(planned_return_date)
    |> max(0)
  end

  @spec monday?(%NaiveDateTime{}) :: boolean()
  def monday?(datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Date.day_of_week()
    |> Kernel.==(1)
  end

  @spec calculate_late_fee(String.t(), String.t(), integer()) :: integer()
  def calculate_late_fee(checkout, return, rate) do
    return_dt = datetime_from_string(return)

    fee =
      checkout
      |> datetime_from_string()
      |> return_date()
      |> days_late(return_dt)
      |> Kernel.*(rate)

    if monday?(return_dt) do
      Integer.floor_div(fee, 2)
    else
      fee
    end
  end
end
