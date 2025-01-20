defmodule Username do
  @doc """
  Sanitises the username.

  - ä becomes ae
  - ö becomes oe
  - ü becomes ue
  - ß becomes ss
  - any other characters that are not a-z or an underscore are removed
  """
  @spec sanitize(charlist()) :: charlist()
  def sanitize(username_chars, cleaned_chars \\ [])
  def sanitize([], res), do: Enum.reverse(res)
  def sanitize([c | cs], res) when c == ?ä, do: sanitize(cs, [?e, ?a | res])
  def sanitize([c | cs], res) when c == ?ö, do: sanitize(cs, [?e, ?o | res])
  def sanitize([c | cs], res) when c == ?ü, do: sanitize(cs, [?e, ?u | res])
  def(sanitize([c | cs], res) when c == ?ß, do: sanitize(cs, [?s, ?s | res]))
  def sanitize([c | cs], res) when c in ?a..?z or c == ?_, do: sanitize(cs, [c | res])
  def sanitize([_ | cs], res), do: sanitize(cs, res)
end
