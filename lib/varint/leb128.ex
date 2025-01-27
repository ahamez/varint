defmodule Varint.LEB128 do
  @moduledoc """
  This module provides functions to convert unsigned integers to and from LEB128 encoded integers.

      iex> Varint.LEB128.encode(12345)
      <<185, 96>>

      iex> Varint.LEB128.decode(<<185, 96>>)
      {12345, <<>>}

  Note that if you intend to work with signed integers, you'll need the Zigzag module as well:

      iex> -10 |> Varint.Zigzag.encode() |> Varint.LEB128.encode()
      <<19>>

      iex> <<19>> |> Varint.LEB128.decode() |> elem(0) |> Varint.Zigzag.decode()
      -10
  """

  import Bitwise

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
  def encode(v) when v < 1 <<< 7,
    do: <<v>>

  def encode(v) when v < 1 <<< 14,
    do: <<1::1, v::7, v >>> 7>>

  def encode(v) when v < 1 <<< 21,
    do: <<1::1, v::7, 1::1, v >>> 7::7, v >>> 14>>

  def encode(v) when v < 1 <<< 28,
    do: <<1::1, v::7, 1::1, v >>> 7::7, 1::1, v >>> 14::7, v >>> 21>>

  def encode(v) when v < 1 <<< 35,
    do: <<1::1, v::7, 1::1, v >>> 7::7, 1::1, v >>> 14::7, 1::1, v >>> 21::7, v >>> 28>>

  def encode(v) when v < 1 <<< 42,
    do:
      <<1::1, v::7, 1::1, v >>> 7::7, 1::1, v >>> 14::7, 1::1, v >>> 21::7, 1::1, v >>> 28::7,
        v >>> 35>>

  def encode(v) when v < 1 <<< 49,
    do:
      <<1::1, v::7, 1::1, v >>> 7::7, 1::1, v >>> 14::7, 1::1, v >>> 21::7, 1::1, v >>> 28::7,
        1::1, v >>> 35::7, v >>> 42>>

  def encode(v) when v < 1 <<< 56,
    do:
      <<1::1, v::7, 1::1, v >>> 7::7, 1::1, v >>> 14::7, 1::1, v >>> 21::7, 1::1, v >>> 28::7,
        1::1, v >>> 35::7, 1::1, v >>> 42::7, v >>> 49>>

  def encode(v), do: <<1::1, v::7, encode(v >>> 7)::binary>>

  @doc """
    Decodes LEB128 encoded bytes to an unsigned integer.

    Returns a tuple where the first element is the decoded value and the second
    element the bytes which have not been parsed.

    This function will raise `ArgumentError` if the given `b` is not a valid LEB128 integer.

      iex> Varint.LEB128.decode(<<172, 2>>)
      {300, <<>>}

      iex> Varint.LEB128.decode(<<172, 2, 0>>)
      {300, <<0>>}

      iex> Varint.LEB128.decode(<<0>>)
      {0, <<>>}

      iex> Varint.LEB128.decode(<<1>>)
      {1, <<>>}

      iex> Varint.LEB128.decode(<<218>>)
      ** (ArgumentError) not a valid LEB128 encoded integer
  """
  @spec decode(binary) :: {non_neg_integer, binary}
  def decode(<<0::1, byte0::7, rest::binary>>),
    do: {byte0, rest}

  def decode(<<1::1, byte1::7, 0::1, byte0::7, rest::binary>>),
    do: {byte1 <<< 0 ||| byte0 <<< 7, rest}

  def decode(<<1::1, byte2::7, 1::1, byte1::7, 0::1, byte0::7, rest::binary>>),
    do: {byte2 <<< 0 ||| byte1 <<< 7 ||| byte0 <<< 14, rest}

  def decode(<<1::1, byte3::7, 1::1, byte2::7, 1::1, byte1::7, 0::1, byte0::7, rest::binary>>),
    do: {byte3 <<< 0 ||| byte2 <<< 7 ||| byte1 <<< 14 ||| byte0 <<< 21, rest}

  def decode(
        <<1::1, byte4::7, 1::1, byte3::7, 1::1, byte2::7, 1::1, byte1::7, 0::1, byte0::7,
          rest::binary>>
      ),
      do: {byte4 <<< 0 ||| byte3 <<< 7 ||| byte2 <<< 14 ||| byte1 <<< 21 ||| byte0 <<< 28, rest}

  def decode(
        <<1::1, byte5::7, 1::1, byte4::7, 1::1, byte3::7, 1::1, byte2::7, 1::1, byte1::7, 0::1,
          byte0::7, rest::binary>>
      ),
      do:
        {byte5 <<< 0 ||| byte4 <<< 7 ||| byte3 <<< 14 ||| byte2 <<< 21 ||| byte1 <<< 28 |||
           byte0 <<< 35, rest}

  def decode(
        <<1::1, byte6::7, 1::1, byte5::7, 1::1, byte4::7, 1::1, byte3::7, 1::1, byte2::7, 1::1,
          byte1::7, 0::1, byte0::7, rest::binary>>
      ),
      do:
        {byte6 <<< 0 ||| byte5 <<< 7 ||| byte4 <<< 14 ||| byte3 <<< 21 ||| byte2 <<< 28 |||
           byte1 <<< 35 |||
           byte0 <<< 42, rest}

  def decode(
        <<1::1, byte7::7, 1::1, byte6::7, 1::1, byte5::7, 1::1, byte4::7, 1::1, byte3::7, 1::1,
          byte2::7, 1::1, byte1::7, 0::1, byte0::7, rest::binary>>
      ),
      do:
        {byte7 <<< 0 ||| byte6 <<< 7 ||| byte5 <<< 14 ||| byte4 <<< 21 ||| byte3 <<< 28 |||
           byte2 <<< 35 |||
           byte1 <<< 42 |||
           byte0 <<< 49, rest}

  def decode(b), do: do_decode(0, 0, b)

  # -- Private

  @spec do_decode(non_neg_integer, non_neg_integer, binary) :: {non_neg_integer, binary}
  defp do_decode(result, shift, <<0::1, byte::7, rest::binary>>) do
    {result ||| byte <<< shift, rest}
  end

  defp do_decode(result, shift, <<1::1, byte::7, rest::binary>>) do
    do_decode(
      result ||| byte <<< shift,
      shift + 7,
      rest
    )
  end

  defp do_decode(_result, _shift, _bin) do
    raise ArgumentError, "not a valid LEB128 encoded integer"
  end
end
