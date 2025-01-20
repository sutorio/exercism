defmodule WineCellar do
  def explain_colors do
    [
      white: "Fermented without skin contact.",
      red: "Fermented with skin contact using dark-colored grapes.",
      rose: "Fermented with some skin contact, but not enough to qualify as a red wine."
    ]
  end

  def filter(cellar, color, opts \\ []) do
    year = Keyword.get(opts, :year)
    country = Keyword.get(opts, :country)

    Enum.flat_map(cellar, fn {wine_color, wine_info} ->
      {_, wine_year, wine_country} = wine_info

      with true <- wine_color == color,
           true <- year == nil or wine_year == year,
           true <- country == nil or wine_country == country do
        [wine_info]
      else
        _ -> []
      end
    end)
  end
end
