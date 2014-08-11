defmodule OSC.DataTest do
  use ExUnit.Case

  setup do
    assert byte_size(message1_bin) == 32
    assert byte_size(message2_bin) == 40
    {:ok, message1_data: create_message1, message2_data: create_message2}
  end

  defp create_message1 do
    %OSC.Data.Message{address: "/oscillator/4/frequency", args: [440.0]}
  end
  defp message1_bin do
    "/oscillator/4/frequency" <> <<0>> <> ",f" <> <<0, 0>> <> <<0x43, 0xdc, 0, 0>>
  end

  defp create_message2 do
    %OSC.Data.Message{address: "/foo", args: [1000, -1, "hello", 1.234, 5.678]}
  end
  defp message2_bin do
    "/foo" <> <<0, 0, 0, 0>> <> ",iisff" <> <<0, 0>> <> <<0x3e8 :: 32>> <>
      <<0xffffffff :: 32>> <> "hello" <> <<0 :: 24>> <> <<0x3f, 0x9d, 0xf3, 0xb6>> <>
      <<0x40, 0xb5, 0xb2, 0x2d>>
  end

  test "Encode message1", %{message1_data: message} do
    assert OSC.Data.encode(message) == message1_bin
  end

  test "Encode message2", %{message2_data: message} do
    assert OSC.Data.encode(message) == message2_bin
  end

  test "Decode message1", %{message1_data: message} do
    assert OSC.Data.decode message1_bin == :not_implemented
  end

  test "Decode message2", %{message2_data: message} do
    assert OSC.Data.decode message2_bin == :not_implemented
  end
end
