defmodule Varint.LEB128 do

  use Bitwise


  @doc """
    Encodes an unsigned integer using LEB128 compression.

      iex> Varint.LEB128.encode(300)
      <<172, 2>>

      iex> Varint.LEB128.encode(0)
      <<0>>

      iex> Varint.LEB128.encode(1)
      <<1>>
  """
  @spec encode(non_neg_integer) :: binary
  def encode(v) when v < 128, do: <<v>>
  def encode(v)             , do: <<1::1, (v &&& 127)::7, encode(v >>> 7)::binary>>


  @doc """
    Decodes LEB128 encoded bytes to an unsigned integer.

      iex> Varint.LEB128.decode(<<172, 2>>)
      300

      iex> Varint.LEB128.decode(<<0>>)
      0

      iex> Varint.LEB128.decode(<<1>>)
      1
  """
  @spec decode(binary) :: non_neg_integer
  def decode(<<b>>), do: b
  def decode(b)    , do: do_decode(0, 0, b)


  # -- Private


  @spec do_decode(non_neg_integer, non_neg_integer, binary) :: non_neg_integer
  defp do_decode(result, shift, <<0::1, byte::7>>) do
    result ||| (byte <<< shift)
  end
  defp do_decode(result, shift, <<1::1, byte::7, rest::binary>>) do
    do_decode(
      result ||| (byte <<< shift),
      shift + 7,
      rest
    )
  end

end
