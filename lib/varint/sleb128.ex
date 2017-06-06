
defmodule Varint.SLEB128 do
  
  @moduledoc """
    Functions for decoding and encoding Signed LEB128 (SLEB128) encoded integers
  
    For handling unsigned integers see `Varint.ULEB128`
  """

  use Bitwise

  @doc """
    Encodes an integer into a signed LEB128 binary

      iex> Varint.SLEB128.encode(-5)
      <<123>>

      iex> Varint.SLEB128.encode(-129)
      <<255, 126>>
      
      iex> Varint.SLEB128.encode(-624485)
      <<155, 241, 89>>

      iex> Varint.SLEB128.encode(127)
      <<255>>

      iex> Varint.SLEB128.encode(129)
      <<129, 1>>

      iex> Varint.SLEB128.encode(0)
      <<0>>
  """
  @spec encode(integer) :: binary
  def encode(v) when v <= 127 and v >= -128, do: <<(if v > 0, do: 1, else: 0)::1, v::7>>
  def encode(v) when v < 0, do: <<1::1, v::7, encode(v >>> 7)::binary>>
  def encode(v) when v > 0, do: <<encode(v >>> 7)::binary, 0::1, v::7>>
  def encode(0), do: <<0>>

  @doc """
    Decodes a signed LEB128 encoded binary into an integer
  
      iex> Varint.SLEB128.decode(<<123>>)
      -5

      iex> Varint.SLEB128.decode(<<155, 241, 89>>)
      -624485

      iex> Varint.SLEB128.decode(<<255>>)
      127

      iex> Varint.SLEB128.decode(<<129, 1>>)
      129
  """
  @spec decode(binary) :: integer
  def decode(b), do: do_decode(0, 0, b) 

  defp do_decode(result, shift, <<group::8, rest::binary>>) do
    # ...
  end
end
