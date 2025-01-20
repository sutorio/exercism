defmodule BoutiqueSuggestions do
  @type item() :: %{
          item_name: String.t(),
          price: float(),
          color: String.t(),
          base_color: String.t()
        }

  @spec get_combinations([item()], [item()], map()) :: [{item(), item()}]
  def get_combinations(tops, bottoms, options \\ []) do
    for top <- tops,
        bottom <- bottoms,
        top.base_color != bottom.base_color,
        top.price + bottom.price <= Keyword.get(options, :maximum_price, 100) do
      {top, bottom}
    end
  end
end
