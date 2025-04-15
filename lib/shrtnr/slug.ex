defmodule Shrtnr.Slug do
  @length 6
  @alphabet ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  @spec generate() :: String.t()
  def generate do
    for _ <- 1..@length, into: "", do: <<Enum.random(@alphabet)>>
  end
end
