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
  def decode(b) when is_binary(b), do: do_decode(0, 0, b)

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
