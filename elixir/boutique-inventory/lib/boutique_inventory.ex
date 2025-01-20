defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    Enum.sort_by(inventory, & &1.price, :asc)
  end

  def with_missing_price(inventory) do
    Enum.filter(inventory, &is_nil(&1.price))
  end

  def update_names(inventory, old_word, new_word) do
    Enum.map(inventory, fn entry ->
      Map.put(entry, :name, String.replace(entry.name, old_word, new_word))
    end)
  end

  def increase_quantity(item, count) do
    Map.put(
      item,
      :quantity_by_size,
      Map.new(item.quantity_by_size, fn {size, qty} -> {size, qty + count} end)
    )
  end

  def total_quantity(item) do
    Enum.sum_by(item.quantity_by_size, fn {_, quantity} -> quantity end)
  end
end
