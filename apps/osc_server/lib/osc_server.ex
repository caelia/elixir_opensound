defmodule OSC.Server do
  use Behaviour

  def init() do
  end

  def start() do
  end

  def shutdown() do
  end

  defcallback receive() :: none

  defcallback setup() :: none
end
