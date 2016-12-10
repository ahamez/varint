defmodule Varint.LEB128Test do

  use ExUnit.Case
  doctest Varint.LEB128

  test "Symmetric" do
    Enum.each(0..32768,
    fn x ->
      assert (x |> Varint.LEB128.encode() |> Varint.LEB128.decode()) == x
    end)
  end

end
