defmodule FreelancerRates do
  @billable_hours_per_day 8.0
  @billable_days_per_month 22.0

  def daily_rate(hourly_rate) do
    @billable_hours_per_day * hourly_rate
  end

  def apply_discount(before_discount, discount \\ 0) do
    discount_multiplier = (100 - discount) / 100

    before_discount * discount_multiplier
  end

  def monthly_rate(hourly_rate, discount \\ 0) do
    monthly_rate_with_discount =
      hourly_rate
      |> daily_rate()
      |> apply_discount(discount)
      |> Kernel.*(@billable_days_per_month)

    # NOTE: specification is that this is rounded up to the nearest integer
    Kernel.trunc(Float.ceil(monthly_rate_with_discount))
  end

  def days_in_budget(budget, hourly_rate, discount \\ 0) do
    rate_with_discount =
      hourly_rate
      |> daily_rate()
      |> apply_discount(discount)

    # NOTE: specification is that this is rounded down, and with one decimal place
    Float.floor(budget / rate_with_discount, 1)
  end
end
