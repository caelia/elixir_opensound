defmodule OSC.DataTest do
  use ExUnit.Case

  defp message1 do
    "/oscillator/4/frequency" <> <<0>> <> ",f" <> <<0, 0>> <> <<0x43, 0xdc, 0, 0>>
  end

  defp message2 do
    "/foo" <> <<0, 0, 0, 0>> <> ",iisff" <> <<0, 0>> <> <<0x3e8 :: 32>> <>
      <<0xffffffff :: 32>> <> "hello" <> <<0 :: 24>> <> <<0x3f, 0x9d, 0xf3, 0xb6>> <>
      <<0x40, 0xb5, 0xb2, 0x2d>>
  end
end
