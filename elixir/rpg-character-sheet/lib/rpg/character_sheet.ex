defmodule RPG.CharacterSheet do
  @spec welcome() :: :ok
  def welcome() do
    "Welcome! Let's fill out your character sheet together."
    |> IO.puts()
  end

  @spec ask_name() :: String.t()
  def ask_name() do
    "What is your character's name?\n"
    |> IO.gets()
    |> String.trim()
  end

  @spec ask_class() :: String.t()
  def ask_class() do
    "What is your character's class?\n"
    |> IO.gets()
    |> String.trim()
  end

  @spec ask_level() :: integer()
  def ask_level() do
    "What is your character's level?\n"
    |> IO.gets()
    |> Integer.parse()
    |> elem(0)
  end

  @spec run() :: %{name: String.t(), class: String.t(), level: integer()}
  def run() do
    welcome()

    Map.new()
    |> Map.put(:name, ask_name())
    |> Map.put(:class, ask_class())
    |> Map.put(:level, ask_level())
    |> IO.inspect(label: "Your character")
  end
end
