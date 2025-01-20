defmodule BirdCount do
  def today([]), do: nil
  def today([n | _]), do: n

  def increment_day_count([]), do: [1]
  def increment_day_count([n | ns]), do: [n + 1 | ns]

  def has_day_without_birds?([]), do: false
  def has_day_without_birds?([n | _ns]) when n == 0, do: true
  def has_day_without_birds?([_n | ns]), do: has_day_without_birds?(ns)

  def total(daily_counts, total \\ 0)
  def total([], total), do: total
  def total([n | ns], total), do: total(ns, total + n)

  def busy_days(daily_counts, total \\ 0)
  def busy_days([], total), do: total
  def busy_days([n | ns], total) when n < 5, do: busy_days(ns, total)
  def busy_days([n | ns], total), do: busy_days(ns, total + 1)
end
