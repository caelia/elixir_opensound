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

  def decode(binary) do
    :not_implemented
  end
end
