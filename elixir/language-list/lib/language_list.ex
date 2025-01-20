defmodule LanguageList do
  def new() do
    []
  end

  def add(languages, new_language) do
    [new_language | languages]
  end

  def remove([_language | remaining_languages]) do
    remaining_languages
  end

  def first([language | _remaining_languages]) do
    language
  end

  def count(languages) do
    Enum.count(languages)
  end

  def functional_list?(languages) do
    Enum.member?(languages, "Elixir")
  end
end
