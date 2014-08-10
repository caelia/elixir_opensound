defmodule OSC.DataTest do
  use ExUnit.Case

  setup do
    assert String.byte_size message1_bin == 32
    assert String.byte_size message2_bin == 40
  end

  defp message1_data do
    {:message, "/oscillator/4/frequency", [440.0]}
  end
  defp message1_bin do
    "/oscillator/4/frequency" <> <<0>> <> ",f" <> <<0, 0>> <> <<0x43, 0xdc, 0, 0>>
  end

  defp message2_data do
    {:message, "/foo", [1000, -1, "hello", 1.234, 5.678]}
  end
  defp message2_bin do
    "/foo" <> <<0, 0, 0, 0>> <> ",iisff" <> <<0, 0>> <> <<0x3e8 :: 32>> <>
      <<0xffffffff :: 32>> <> "hello" <> <<0 :: 24>> <> <<0x3f, 0x9d, 0xf3, 0xb6>> <>
      <<0x40, 0xb5, 0xb2, 0x2d>>
  end

  test "Encode message1" do
    assert OSC.Data.encode message1_data == message1_bin
  end

  test "Encode message2" do
    assert OSC.Data.encode message2_data == message2_bin
  end

  test "Decode message1" do
    assert OSC.Data.decode message1_bin == message1_data
  end

  test "Decode message2" do
    assert OSC.Data.decode message2_bin == message2_data
  end
end
