defmodule Varint.SLEB128Test do

  use ExUnit.Case
  doctest Varint.SLEB128

  # test "Symmetric" do
  #   Enum.each(0..32768,
  #   fn x ->
  #     assert (x |> Varint.SLEB128.encode() |> Varint.SLEB128.decode()) == {x, <<>>}
  #   end)
  # end
end
