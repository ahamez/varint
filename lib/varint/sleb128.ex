defmodule Varint.SLEB128 do
  @moduledoc """
  This module provides functions to convert signed integers to and from SLEB128 encoded integers.

      iex> Varint.SLEB128.encode(-624485)
      <<155, 241, 89>>

      iex> Varint.SLEB128.decode(<<155, 241, 89>>)
      {-624485, <<>>}
  """

  import Bitwise

  @doc """
    Encodes a signed integer using SLEB128 compression.

      iex> Varint.SLEB128.encode(0)
      <<0>>

      iex> Varint.SLEB128.encode(1)
      <<1>>

      iex> Varint.SLEB128.encode(-1)
      <<127>>

      iex> Varint.SLEB128.encode(624485)
      <<229, 142, 38>>
  """
  @spec encode(integer) :: binary
  def encode(v) when v >= -(1 <<< 6) and v < 1 <<< 6,
    do: <<v &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 13) and v < 1 <<< 13,
    do: <<(v &&& 0x7F) ||| 0x80, v >>> 7 &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 20) and v < 1 <<< 20,
    do: <<(v &&& 0x7F) ||| 0x80, (v >>> 7 &&& 0x7F) ||| 0x80, v >>> 14 &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 27) and v < 1 <<< 27,
    do:
      <<(v &&& 0x7F) ||| 0x80, (v >>> 7 &&& 0x7F) ||| 0x80, (v >>> 14 &&& 0x7F) ||| 0x80,
        v >>> 21 &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 34) and v < 1 <<< 34,
    do:
      <<(v &&& 0x7F) ||| 0x80, (v >>> 7 &&& 0x7F) ||| 0x80, (v >>> 14 &&& 0x7F) ||| 0x80,
        (v >>> 21 &&& 0x7F) ||| 0x80, v >>> 28 &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 41) and v < 1 <<< 41,
    do:
      <<(v &&& 0x7F) ||| 0x80, (v >>> 7 &&& 0x7F) ||| 0x80, (v >>> 14 &&& 0x7F) ||| 0x80,
        (v >>> 21 &&& 0x7F) ||| 0x80, (v >>> 28 &&& 0x7F) ||| 0x80, v >>> 35 &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 48) and v < 1 <<< 48,
    do:
      <<(v &&& 0x7F) ||| 0x80, (v >>> 7 &&& 0x7F) ||| 0x80, (v >>> 14 &&& 0x7F) ||| 0x80,
        (v >>> 21 &&& 0x7F) ||| 0x80, (v >>> 28 &&& 0x7F) ||| 0x80, (v >>> 35 &&& 0x7F) ||| 0x80,
        v >>> 42 &&& 0x7F>>

  def encode(v) when v >= -(1 <<< 55) and v < 1 <<< 55,
    do:
      <<(v &&& 0x7F) ||| 0x80, (v >>> 7 &&& 0x7F) ||| 0x80, (v >>> 14 &&& 0x7F) ||| 0x80,
        (v >>> 21 &&& 0x7F) ||| 0x80, (v >>> 28 &&& 0x7F) ||| 0x80, (v >>> 35 &&& 0x7F) ||| 0x80,
        (v >>> 42 &&& 0x7F) ||| 0x80, v >>> 49 &&& 0x7F>>

  def encode(v) when is_integer(v), do: do_encode(v, [])

  @doc """
    Decodes SLEB128 encoded bytes to a signed integer.

    Returns a tuple where the first element is the decoded value and the second
    element the bytes which have not been parsed.

    This function will raise `ArgumentError` if the given `b` is not a valid SLEB128 integer.

      iex> Varint.SLEB128.decode(<<229, 142, 38>>)
      {624485, <<>>}

      iex> Varint.SLEB128.decode(<<229, 142, 38, 0>>)
      {624485, <<0>>}

      iex> Varint.SLEB128.decode(<<0>>)
      {0, <<>>}

      iex> Varint.SLEB128.decode(<<127>>)
      {-1, <<>>}

      iex> Varint.SLEB128.decode(<<128>>)
      ** (ArgumentError) not a valid SLEB128 encoded integer
  """
  @spec decode(binary) :: {integer, binary}
  def decode(b), do: do_decode(0, 0, b)

  # -- Private

  @spec do_encode(integer, iodata) :: binary
  defp do_encode(v, acc) do
    byte = v &&& 0x7F
    next = v >>> 7
    sign_set = (byte &&& 0x40) != 0
    done = (next == 0 and not sign_set) or (next == -1 and sign_set)
    byte = if done, do: byte, else: byte ||| 0x80
    acc = [acc, <<byte>>]

    if done do
      IO.iodata_to_binary(acc)
    else
      do_encode(next, acc)
    end
  end

  @spec do_decode(integer, non_neg_integer, binary) :: {integer, binary}
  defp do_decode(result, shift, <<0::1, byte::7, rest::binary>>) do
    result = result ||| byte <<< shift

    if (byte &&& 0x40) == 0 do
      {result, rest}
    else
      {result ||| -1 <<< (shift + 7), rest}
    end
  end

  defp do_decode(result, shift, <<1::1, byte::7, rest::binary>>) do
    do_decode(result ||| byte <<< shift, shift + 7, rest)
  end

  defp do_decode(_result, _shift, _bin) do
    raise ArgumentError, "not a valid SLEB128 encoded integer"
  end
end
