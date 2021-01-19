defmodule Varint.LEB128Test do
  use ExUnit.Case, async: true
  doctest Varint.LEB128

  test "Symmetric" do
    Enum.each(
      0..32_768,
      fn x ->
        assert x |> Varint.LEB128.encode() |> Varint.LEB128.decode() == {x, <<>>}
      end
    )
  end

  test "Decode raises an error for non-LEB128 encoded data" do
    assert_raise ArgumentError, fn -> Varint.LEB128.decode(<<255>>) end
  end
end
