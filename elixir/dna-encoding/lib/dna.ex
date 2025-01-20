defmodule DNA do
  @spec encode_nucleotide(integer) :: integer
  def encode_nucleotide(code_point) do
    case code_point do
      ?\s -> 0b0000
      ?A -> 0b0001
      ?C -> 0b0010
      ?G -> 0b0100
      ?T -> 0b1000
      _ -> raise "Invalid nucleotide: #{code_point}"
    end
  end

  @spec decode_nucleotide(integer) :: integer
  def decode_nucleotide(encoded_code) do
    case encoded_code do
      0b0000 -> ?\s
      0b0001 -> ?A
      0b0010 -> ?C
      0b0100 -> ?G
      0b1000 -> ?T
      _ -> raise "Invalid encoded nucleotide: #{encoded_code}"
    end
  end

  @spec encode(list(char()), bitstring()) :: bitstring()
  def encode(dna_chars, result \\ <<>>)
  def encode([], res), do: res

  def encode([char | chars], res) do
    encoded_char = encode_nucleotide(char)
    # NOTE: default for bitstring is big-endian, so we append the encoded char
    encode(chars, <<res::bitstring, encoded_char::size(4)>>)
  end

  @spec decode(bitstring()) :: list(char())
  def decode(dna, result \\ [])
  def decode(<<>>, res), do: Enum.reverse(res)

  def decode(<<encoded_char::size(4), rest::bitstring>>, res) do
    decoded_char = decode_nucleotide(encoded_char)
    decode(rest, [decoded_char | res])
  end
end
