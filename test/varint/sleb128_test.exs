defmodule SLEB128Simple do
  import Bitwise

  @spec encode(integer) :: binary()
  def encode(v), do: do_encode(v, [])

  @spec decode(binary) :: {integer, binary}
  def decode(b), do: do_decode(0, 0, b)

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
end

defmodule Varint.SLEB128Test do
  import Bitwise
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Varint.SLEB128

  property "Encoding produces the same result as the reference implementation" do
    check all int <- integer(-(1 <<< 63)..(1 <<< 63)) do
      assert Varint.SLEB128.encode(int) == SLEB128Simple.encode(int)
    end
  end

  property "Decoding produces the same result as the reference implementation" do
    check all int <- integer(-(1 <<< 63)..(1 <<< 63)) do
      encoded = SLEB128Simple.encode(int)
      assert Varint.SLEB128.decode(encoded) == SLEB128Simple.decode(encoded)
    end
  end

  property "Symmetric" do
    check all int <- integer(-(1 <<< 63)..(1 <<< 63)) do
      assert int |> Varint.SLEB128.encode() |> Varint.SLEB128.decode() == {int, ""}
    end
  end

  test "Encode" do
    assert Varint.SLEB128.encode(0) == <<0>>
    assert Varint.SLEB128.encode(1) == <<1>>
    assert Varint.SLEB128.encode(-1) == <<0x7F>>
    assert Varint.SLEB128.encode(63) == <<0x3F>>
    assert Varint.SLEB128.encode(64) == <<0xC0, 0x00>>
    assert Varint.SLEB128.encode(-64) == <<0x40>>
    assert Varint.SLEB128.encode(-65) == <<0xBF, 0x7F>>
    assert Varint.SLEB128.encode(624_485) == <<0xE5, 0x8E, 0x26>>
    assert Varint.SLEB128.encode(-624_485) == <<0x9B, 0xF1, 0x59>>
  end

  test "Decode" do
    assert Varint.SLEB128.decode(<<0>>) == {0, ""}
    assert Varint.SLEB128.decode(<<0x7F>>) == {-1, ""}
    assert Varint.SLEB128.decode(<<0xE5, 0x8E, 0x26>>) == {624_485, ""}
    assert Varint.SLEB128.decode(<<0x9B, 0xF1, 0x59>>) == {-624_485, ""}
    assert Varint.SLEB128.decode(<<0x9B, 0xF1, 0x59, 0>>) == {-624_485, <<0>>}
  end

  test "Decode raises an error for non-SLEB128 encoded data" do
    assert_raise ArgumentError, fn -> Varint.SLEB128.decode(<<255>>) end
    assert_raise ArgumentError, fn -> Varint.SLEB128.decode(<<128>>) end
  end
end
