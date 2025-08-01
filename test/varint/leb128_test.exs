defmodule VarintSimple do
  import Bitwise

  @spec encode(integer) :: binary()
  def encode(v) when v < 1 <<< 7, do: <<v>>
  def encode(v), do: <<1::1, v::7, encode(v >>> 7)::binary>>

  @spec decode(binary) :: {non_neg_integer, binary}
  def decode(<<0::1, byte0::7, rest::binary>>), do: {byte0, rest}
  def decode(b), do: do_decode(0, 0, b)

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
end

defmodule Varint.LEB128Test do
  import Bitwise
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Varint.LEB128

  property "Unrolled encoding produces the same result as the reference implementation" do
    check all int <- integer(0..(1 <<< 64)) do
      assert Varint.LEB128.encode(int) == VarintSimple.encode(int)
    end
  end

  property "Unrolled decoding produces the same result as the reference implementation" do
    check all int <- integer(0..(1 <<< 64)) do
      encoded = VarintSimple.encode(int)
      assert Varint.LEB128.decode(encoded) == VarintSimple.decode(encoded)
    end
  end

  property "Symmetric" do
    check all int <- integer(0..(1 <<< 64)) do
      assert int |> Varint.LEB128.encode() |> Varint.LEB128.decode() == {int, ""}
    end
  end

  test "Encode" do
    assert Varint.LEB128.encode(0) == <<0>>
    assert Varint.LEB128.encode(1) == <<1>>

    assert Varint.LEB128.encode((1 <<< 14) - 1) == <<0xFF, 0x7F>>
    assert Varint.LEB128.encode(1 <<< 14) == <<0x80, 0x80, 0x1>>

    assert Varint.LEB128.encode((1 <<< 21) - 1) == <<0xFF, 0xFF, 0x7F>>
    assert Varint.LEB128.encode(1 <<< 21) == <<0x80, 0x80, 0x80, 0x1>>

    assert Varint.LEB128.encode((1 <<< 28) - 1) == <<0xFF, 0xFF, 0xFF, 0x7F>>
    assert Varint.LEB128.encode(1 <<< 28) == <<0x80, 0x80, 0x80, 0x80, 0x1>>

    assert Varint.LEB128.encode((1 <<< 35) - 1) == <<0xFF, 0xFF, 0xFF, 0xFF, 0x7F>>
    assert Varint.LEB128.encode(1 <<< 35) == <<0x80, 0x80, 0x80, 0x80, 0x80, 0x1>>

    assert Varint.LEB128.encode((1 <<< 42) - 1) == <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F>>
    assert Varint.LEB128.encode(1 <<< 42) == <<0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x1>>

    assert Varint.LEB128.encode((1 <<< 56) - 1) ==
             <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F>>

    assert Varint.LEB128.encode(1 <<< 56) ==
             <<0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x1>>

    assert Varint.LEB128.encode((1 <<< 63) - 1) ==
             <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F>>

    assert Varint.LEB128.encode(1 <<< 63) ==
             <<0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x1>>
  end

  test "Decode raises an error for non-LEB128 encoded data" do
    assert_raise ArgumentError, fn -> Varint.LEB128.decode(<<255>>) end
    assert_raise ArgumentError, fn -> Varint.LEB128.decode(<<128>>) end
  end
end
