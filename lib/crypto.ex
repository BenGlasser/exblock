defmodule Crypto do
  @moduledoc """
  Cryptographic functions for blockchain operations.
  """

  # Specify which fields to hash in a block
  @hash_fields [:data, :timestamp, :prev_hash]

  @doc """
  Calculate basic hash of input data.
  """
  def hash(data) do
    data
    |> Poison.encode!()
    |> (&:crypto.hash(:sha256, &1)).()
    |> Base.encode16(case: :lower)
  end

  @doc "Calculate hash of block"
  def hash(%{} = block) do
    block
    |> Map.take(@hash_fields)
    |> Poison.encode!
    |> sha256
  end

  # Calculate SHA256 for a binary string
  defp sha256(binary) do
    :crypto.hash(:sha256, binary) |> Base.encode16
  end
end
