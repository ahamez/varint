defmodule Varint.LEB128Test do
  import Bitwise
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Varint.LEB128

  property "Unrolled encoding produces the same result as the reference implementation" do
    check all int <- integer(0..(1 <<< 64)) do
      assert Varint.LEB128.encode(int) == encode_reference(int)
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
  end

  test "Decode raises an error for non-LEB128 encoded data" do
    assert_raise ArgumentError, fn -> Varint.LEB128.decode(<<255>>) end
  end

  defp encode_reference(v) when v < 1 <<< 7, do: <<v>>
  defp encode_reference(v), do: <<1::1, v::7, encode_reference(v >>> 7)::binary>>
end
