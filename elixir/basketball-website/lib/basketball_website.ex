defmodule BasketballWebsite do
  @spec extract_from_path(Map.t(), String.t() | [String.t()]) :: String.t() | nil
  def extract_from_path(data, path) when is_binary(path) do
    extract_from_path(data, String.split(path, "."))
  end

  def extract_from_path(data, [key]), do: data[key]

  def extract_from_path(data, [key | keys]) do
    if data[key] == nil do
      nil
    else
      extract_from_path(data[key], keys)
    end
  end

  def get_in_path(data, path) do
    get_in(data, String.split(path, "."))
  end
end
