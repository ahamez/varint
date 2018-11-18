defmodule Varint.Zigzag do

  @moduledoc """
  This module provides functions to work with signed integers.
  """

  use Bitwise

  @doc """
    Encodes a signed integer into an unsigned integer suitable for LEB128 encoding.

      iex> Varint.Zigzag.encode(0)
      0

      iex> Varint.Zigzag.encode(-1)
      1

      iex> Varint.Zigzag.encode(1)
      2

      iex> Varint.Zigzag.encode(-2)
      3

      iex> Varint.Zigzag.encode(-2147483648)
      4294967295

      iex> Varint.Zigzag.encode(2147483647)
      4294967294
  """
  @spec encode(integer) :: non_neg_integer
  def encode(v) when v >= 0, do: v * 2
  def encode(v)            , do: v * -2 -1

  @doc """
    Decodes an unsigned integer into a signed integer.

      iex> Varint.Zigzag.decode(0)
      0

      iex> Varint.Zigzag.decode(1)
      -1

      iex> Varint.Zigzag.decode(2)
      1

      iex> Varint.Zigzag.decode(3)
      -2

      iex> Varint.Zigzag.decode(4294967294)
      2147483647

      iex> Varint.Zigzag.decode(4294967295)
      -2147483648
  """
  @spec decode(non_neg_integer) :: integer
  def decode(v) when (v &&& 1) == 0, do: v >>> 1
  def decode(v)                    , do: -((v+1) >>> 1)

end
