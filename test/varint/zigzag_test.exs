defmodule Varint.ZigzagTest do
  use ExUnit.Case
  doctest Varint.Zigzag

  test "Symmetric" do
    Enum.each(
      -32768..32768,
      fn x ->
        assert x |> Varint.Zigzag.encode() |> Varint.Zigzag.decode() == x
      end
    )
  end
end
