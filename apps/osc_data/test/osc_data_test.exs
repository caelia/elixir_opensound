defmodule OSC.DataTest do
  use ExUnit.Case

  setup do
    {struct1, bin1} = create_message1
    {struct2, bin2} = create_message2
    {:ok, message1_struct: struct1, message1_bin: bin1,
          message2_struct: struct2, message2_bin: bin2 }
  end

  defp create_message1 do
    { %OSC.Data.Message{address: "/oscillator/4/frequency", args: [440.0]},
      "/oscillator/4/frequency" <> <<0>> <> ",f" <> <<0, 0>> <> <<0x43, 0xdc, 0, 0>> }
  end

  defp create_message2 do
    { %OSC.Data.Message{address: "/foo", args: [1000, -1, "hello", 1.234, 5.678]},
      "/foo" <> <<0, 0, 0, 0>> <> ",iisff" <> <<0, 0>> <> <<0x3e8 :: 32>> <>
        <<0xffffffff :: 32>> <> "hello" <> <<0 :: 24>> <> <<0x3f, 0x9d, 0xf3, 0xb6>> <>
        <<0x40, 0xb5, 0xb2, 0x2d>> }
  end

  test "Encode message1", %{message1_struct: struct, message1_bin: bin} do
    assert OSC.Data.encode(struct) == bin
  end

  test "Encode message2", %{message2_struct: struct, message2_bin: bin} do
    assert OSC.Data.encode(struct) == bin
  end

  test "Decode message1", %{message1_struct: struct, message1_bin: bin} do
    assert OSC.Data.decode(bin) == struct
  end

  test "Decode message2", %{message2_struct: struct, message2_bin: bin} do
    %{address: test_address, args: [t1, t2, t3, t4, t5]} = OSC.Data.decode(bin)
    %{address: ref_address, args: [r1, r2, r3, r4, r5]} = struct
    assert test_address == ref_address
    assert (t1 == r1 and t2 == r2 and t3 == r3)
    assert_in_delta(t4, r4, 0.0000001)
    assert_in_delta(t5, r5, 0.0000001)
  end
end
