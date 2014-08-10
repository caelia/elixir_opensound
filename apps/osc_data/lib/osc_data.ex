defmodule OSC.Data do
  defprotocol Encoding do
    @doc "Encodes OSC messages and their arguments."
    def encode(data)
  end

  defmodule Message do
    defstruct address: "", type_tags: ",", args: []
  end

  defmodule Bundle do
    defstruct time_tag: 0.0, elements: []
  end

  defmodule Blob do
    defstruct data: ""
  end

  defimpl Encoding, for: Message do
    def encode(%Message{address: ""}) do
      {:error, "Address is missing."}
    end
    def encode(%Message{address: addr, type_tags: tt, args: args}) do
      {tags, body} = Enum.reduce args, {tt, ""}, (
        fn (arg, {acc_tags, acc_data}) ->
          {tag, data} = encode arg
          {acc_tags <> tag, acc_data <> data}
        )
      (pad_string addr) <> (pad_string tags) <> body
    end
  end

  defimpl Encoding, for Bundle do
  end

  defimpl Encoding, for Integer do
    def encode(n) when n > 2147483647 or n < -2147483648
      {:error, "Number out of range."}
    end
    def encode(n) do
      <<n :: 32>>
    end
  end

  defimpl Encoding, for Float do
  end

  defimpl Encoding, for String do
  end

  defimpl Encoding, for Blob do
  end
end
