defmodule Poker do
  @doc """
  Given a list of poker hands, return a list containing the highest scoring hand.

  If two or more hands tie, return the list of tied hands in the order they were received.

  The basic rules and hand rankings for Poker can be found at:

  https://en.wikipedia.org/wiki/List_of_poker_hands

  For this exercise, we'll consider the game to be using no Jokers,
  so five-of-a-kind hands will not be tested. We will also consider
  the game to be using multiple decks, so it is possible for multiple
  players to have identical cards.

  Aces can be used in low (A 2 3 4 5) or high (10 J Q K A) straights, but do not count as
  a high card in the former case.

  For example, (A 2 3 4 5) will lose to (2 3 4 5 6).

  You can also assume all inputs will be valid, and do not need to perform error checking
  when parsing card values. All hands will be a list of 5 strings, containing a number
  (or letter) for the rank, followed by the suit.

  Ranks (lowest to highest): 2 3 4 5 6 7 8 9 10 J Q K A
  Suits (order doesn't matter): C D H S

  Example hand: ~w(4S 5H 4C 5D 4H) # Full house, 5s over 4s
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    hands
    |> Enum.reduce({[], {0, 0, 0, 0, 0, 0}}, fn hand, {best_hands, current_hi_score} ->
      case score_hand(hand) do
        score when score > current_hi_score -> {[hand], score}
        score when score == current_hi_score -> {[hand | best_hands], score}
        _ -> {best_hands, current_hi_score}
      end
    end)
    |> elem(0)
  end

  def score_hand(hand) do
    hand
    |> Hand.parse()
    |> Hand.score()
  end
end

defmodule Hand do
  @moduledoc """
  The logic for parsing and scoring poker hands.

  The parser accepts the list of strings representing a hand, the scorer returns
  a six-integer tuple representing the hand's score - the initial integer represents
  the base score for the hand itself (pair, flush, straight, etc.), with the remaining 
  integers are used for tie breaking.

  The algorithm used is:

  1. Convert the list of strings to a list of characters
  2. Map those characters to tuple of `{rank, bitmask}`, representing rank and suit
  3. Iterate over the {rank, suit} list, updating a struct representing:
     a. an integer representing the suits of the hand, OR'd with suit bitmasks. So,
        for example, the number 10 can be represented in binary as:

        ```
          SHCD
        0b1010
        ```

        This allows checking for flushes. So that hand contains at least one 
        spade and at least one club; not a flush.

     b. a map of `%{ rank => count }`, representing the number of cards for each rank
        in the hand. So for example:

        ```
        %{ 5 => 3, 7 => 2 }
        ```

        So that hand contains three cards of rank 5 and two cards of rank 7, so
        a full house.

        By taking the keys of the map and sorting them, can infer whether a hand
        is a straight by checking there are 5 ranks present which are all consecutive.

        The exception to this is if the straight is of the form "A, 2, 3, 4, 5",
        when aces are considered to be the lowest rank. This can just be directly
        checked.

        If this is sorted by value then by rank, the initial value will allow
        inferring which hand two pairs or three of a kind (which both have 3 ranks), 
        and which hand is a full house and which four of a kind (which both have 2 cards).

  4. Once this is populated, can further process the values to infer all 
     the score of the hand. A 6-element tuple is produced, representing the score
     for the hand as the first element, with the remaining 5 elements representing
     the values of the individual cards. The full five elements can naturally only
     have discrete numbers when all five cards have a different value, so are set
     to zero for the other cases.

     So for example, for two pair:

     ```
       highest pair rank
           │   remaining card is a 10
           │    │
     { 3, 9, 7, 10, 0, 0 }
       │     │ 
       │  lowest pair rank
     :two_pair
     ```

     Two pair beats one pair. If both players have two pair, compare highest pair.
     if highest pairs match, compare lowest pair. If lowest pairs match, compare
     highest card. If they match, it's a tie.
  """
  import Bitwise

  defstruct rank_tallies: Map.new(),
            suits: 0

  @doc """
  Given a charlist representing a card (eg `['2', 'D']`, or `['A', 'H'`]), map 
  that to a two-element tuple with a rank number + a bitmask representing the suit.

  This is _mainly_ to handle the fact that "10" has to be special cased; if all
  the cards were two characters this would be simpler, but unfortunately "10" is
  represented as a charlist of length 3.

  Mapping to masks for suit makes it trivially easy to test for flushes.
  """
  @spec charlist_mapper([char()]) :: {integer(), integer()}
  def charlist_mapper(card_chars) do
    case card_chars do
      [?2, suit] -> {2, suit_mask(suit)}
      [?3, suit] -> {3, suit_mask(suit)}
      [?4, suit] -> {4, suit_mask(suit)}
      [?5, suit] -> {5, suit_mask(suit)}
      [?6, suit] -> {6, suit_mask(suit)}
      [?7, suit] -> {7, suit_mask(suit)}
      [?8, suit] -> {8, suit_mask(suit)}
      [?9, suit] -> {9, suit_mask(suit)}
      [?1, ?0, suit] -> {10, suit_mask(suit)}
      [?J, suit] -> {11, suit_mask(suit)}
      [?Q, suit] -> {12, suit_mask(suit)}
      [?K, suit] -> {13, suit_mask(suit)}
      [?A, suit] -> {14, suit_mask(suit)}
    end
  end

  @spec suit_mask(char()) :: integer()
  defp suit_mask(suit) do
    case suit do
      ?S -> 0b0001
      ?H -> 0b0010
      ?C -> 0b0100
      ?D -> 0b1000
    end
  end

  @doc """
  Providing the rank of a hand as an atom makes the code a little bit clearer,
  but there has to be an ordering of the ranks to allow scoring.
  """
  @spec hand_type_score(atom()) :: integer()
  def hand_type_score(rank) do
    case rank do
      :unknown -> 0
      :high_card -> 1
      :one_pair -> 2
      :two_pair -> 3
      :three_of_a_kind -> 4
      :straight -> 5
      :flush -> 6
      :full_house -> 7
      :four_of_a_kind -> 8
      :straight_flush -> 9
    end
  end

  @spec parse(list(String.t())) :: %Hand{}
  def parse(cards) do
    cards
    |> Stream.map(&String.to_charlist/1)
    |> Stream.map(&charlist_mapper/1)
    |> Enum.reduce(%Hand{}, fn {rank, suit_mask}, hand ->
      %Hand{
        rank_tallies: Map.update(hand.rank_tallies, rank, 1, &(&1 + 1)),
        suits: hand.suits ||| suit_mask
      }
    end)
  end

  @spec score(%Hand{}) :: {integer(), integer(), integer(), integer(), integer(), integer()}
  def score(hand) do
    discrete_ranks = map_size(hand.rank_tallies)
    sorted_tallies = Enum.sort_by(hand.rank_tallies, fn {r, c} -> {c, r} end, :desc)
    [{toprank, topcount} | _rest] = sorted_tallies

    flush? = hand.suits in [1, 2, 4, 8]

    sorted_ranks = Enum.map(sorted_tallies, fn {r, _} -> r end)

    low_straight? = sorted_ranks == [14, 5, 4, 3, 2]
    high_straight? = sorted_ranks == [toprank, toprank - 1, toprank - 2, toprank - 3, toprank - 4]

    case {discrete_ranks, topcount, flush?, low_straight? or high_straight?} do
      {5, _, false, false} ->
        [a, b, c, d, e] = sorted_ranks
        {hand_type_score(:high_card), a, b, c, d, e}

      {4, _, _, _} ->
        [pair, a, b, c] = sorted_ranks
        {hand_type_score(:one_pair), pair, a, b, c, 0}

      {3, 2, _, _} ->
        [high_pair, low_pair, kicker] = sorted_ranks
        {hand_type_score(:two_pair), high_pair, low_pair, kicker, 0, 0}

      {3, 3, _, _} ->
        [trip, a, b] = sorted_ranks
        {hand_type_score(:three_of_a_kind), trip, a, b, 0, 0}

      {5, _, false, true} ->
        ranks = if(low_straight?, do: [5, 4, 3, 2, 1], else: sorted_ranks)
        List.to_tuple([hand_type_score(:straight) | ranks])

      {5, _, true, false} ->
        [a, b, c, d, e] = sorted_ranks
        {hand_type_score(:flush), a, b, c, d, e}

      {2, 3, _, _} ->
        [trip, pair] = sorted_ranks
        {hand_type_score(:full_house), trip, pair, 0, 0, 0}

      {2, 4, _, _} ->
        [quad, kicker] = sorted_ranks
        {hand_type_score(:four_of_a_kind), quad, kicker, 0, 0, 0}

      {5, _, true, true} ->
        ranks = if(low_straight?, do: [5, 4, 3, 2, 1], else: sorted_ranks)
        List.to_tuple([hand_type_score(:straight_flush) | ranks])

      _ ->
        {hand_type_score(:unknown), 0, 0, 0, 0, 0}
    end
  end
end
