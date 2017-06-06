defmodule Varint.ULEB128Test do

  use ExUnit.Case
  doctest Varint.ULEB128

  test "Symmetric" do
    Enum.each(0..32768,
    fn x ->
      assert (x |> Varint.ULEB128.encode() |> Varint.ULEB128.decode()) == {x, <<>>}
    end)
  end
end
