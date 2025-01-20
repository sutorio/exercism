defmodule KitchenCalculator do
  def get_volume({_unit, volume}), do: volume

  def to_milliliter(volume_pair)
  def to_milliliter({:milliliter, volume}), do: {:milliliter, volume}
  def to_milliliter({:teaspoon, volume}), do: {:milliliter, volume * 5}
  def to_milliliter({:tablespoon, volume}), do: {:milliliter, volume * 15}
  def to_milliliter({:fluid_ounce, volume}), do: {:milliliter, volume * 30}
  def to_milliliter({:cup, volume}), do: {:milliliter, volume * 240}

  def from_milliliter(volume_pair, unit)
  def from_milliliter(vp, :milliliter), do: vp
  def from_milliliter(vp, :teaspoon), do: {:teaspoon, get_volume(to_milliliter(vp)) / 5}
  def from_milliliter(vp, :tablespoon), do: {:tablespoon, get_volume(to_milliliter(vp)) / 15}
  def from_milliliter(vp, :fluid_ounce), do: {:fluid_ounce, get_volume(to_milliliter(vp)) / 30}
  def from_milliliter(vp, :cup), do: {:cup, get_volume(to_milliliter(vp)) / 240}

  def convert(volume_pair, unit), do: from_milliliter(volume_pair, unit)
end
