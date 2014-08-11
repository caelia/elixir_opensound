defmodule OSC.Data do
  defprotocol Encoding do
    @doc "Encodes OSC messages and their arguments."
    def encode(data)
  end

  defmodule Message do
    defstruct address: "", args: []
  end

  defmodule Blob do
    defstruct data: ""
  end

  defmodule Bundle do
    defstruct time_tag: 0, elements: []
  end

  defimpl Encoding, for: Message do
    def encode(%Message{address: addr, args: args}) do
      {tags, body} = Enum.reduce args, {",", ""}, (
        fn (arg, {acc_tags, acc_data}) ->
          {tag, data} = Encoding.encode arg
          {acc_tags <> tag, acc_data <> data}
        end
      )
      {_, final_addr} = Encoding.encode addr
      {_, final_tags} = Encoding.encode tags
      final_addr <> final_tags <> body
    end
  end

  defimpl Encoding, for: Blob do
    def encode(%Blob{data: raw_data}) do
      data = raw_data <> case rem byte_size(raw_data), 4 do
        0 -> <<>>
        1 -> <<0, 0, 0>>
        2 -> <<0, 0>>
        3 -> <<0>>
      end
      {_, len} = Encoding.encode(byte_size data)
      {"b", len <> data}
    end
  end

  defimpl Encoding, for: Bundle do
    def encode(%Bundle{time_tag: _,  elements: _}) do
      :not_implemented
    end
  end

  defimpl Encoding, for: Integer do
    def encode(n) when n > 2147483647 or n < -2147483648 do
      {:error, "Number out of range."}
    end
    def encode(n) do
      {"i", <<n :: 32>>}
    end
  end

  defimpl Encoding, for: Float do
    # Not completely sure about these limits. This is based on 
    # 2 * :math.pow(2, 127), but with the last digit of the significand
    # reduced by 1, because the significand of an IEEE 754 float must be
    # *less than* 2.
    def encode(n) when abs(n) > 3.402823669209384e38 do
      {:error, "Number out of range."}
    end
    def encode(n) do
      {"f", <<n :: float-32>>}
    end
  end

  defimpl Encoding, for: BitString do
    def encode(s) do
      len = byte_size(s)
      data= case rem len, 4 do
        0 -> s <> <<0, 0, 0, 0>>
        1 -> s <> <<0, 0, 0>>
        2 -> s <> <<0, 0>>
        3 -> s <> <<0>>
      end
      {"s", data}
    end
  end

  def encode(x) do
    Encoding.encode x
  end

  defp decode_string(bin) do
    decode_string("", bin)
  end
  defp decode_string(result, <<0, tail::binary>>) do
    mod = rem byte_size(result), 4
    case {mod, tail} do
      {0, <<0, 0, 0, rest::binary>>} -> {result, rest}
      {1, <<0, 0, rest::binary>>} -> {result, rest}
      {2, <<0, rest::binary>>} -> {result, rest}
      {3, <<rest::binary>>} -> {result, rest}
    end
  end
  defp decode_string(result, <<s, rest::binary>>) do
    decode_string result <> <<s>>, rest
  end

  defp decode_int(<<x::signed-32, rest::binary>>) do
    {x, rest}
  end

  defp decode_float(<<x::float-32, rest::binary>>) do
    {x, rest}
  end

  defp decode_blob(0, data) do
    {<<>>, data}
  end
  defp decode_blob(bytes, <<x, tail::binary>>) do
    {new_tail, rest} = decode_blob bytes-1, tail
    {<<x>> <> new_tail, rest}
  end
  defp decode_blob(data) do
    <<size::32, tail>> = data
    {body, rest} = decode_blob size, tail
    {%Blob{data: body}, rest}
  end

  def decode_message_args("", _) do
    []
  end
  def decode_message_args(<<first, rest::binary>>, data) do
    {arg, tail} = case first do
      ?s -> decode_string data
      ?i -> decode_int data
      ?f -> decode_float data
      ?b -> decode_blob data
    end
    [arg | decode_message_args rest, tail]
  end

  def decode_message(address, rest) do
    {<<",", tags::binary>>, arg_data} = decode_string rest
    args = decode_message_args(tags, arg_data) 
    %Message{address: address, args: args}
  end

  def decode_bundle(content) do
    :not_implemented
  end

  def decode(binary) do
    {leader, rest} = decode_string(binary)
    case leader do
      "#bundle" -> decode_bundle rest
      <<47, _::binary>> -> decode_message leader, rest
      _ -> {:error, "unknown data type"}
    end
  end
end
