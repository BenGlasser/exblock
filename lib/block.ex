defmodule Block do
  @moduledoc """
  Block structure and operations for the blockchain.
  """

  defstruct [:data, :timestamp, :prev_hash, :hash]

  @doc """
  Create a new block with given data and previous hash.
  """
  def new(data, prev_hash) do
    %Block{
      data: data,
      timestamp: DateTime.utc_now() |> DateTime.to_unix(),
      prev_hash: prev_hash,
      hash: nil
    }
  end

  @doc """
  Create the genesis block (first block in the chain).
  """
  def zero do
    %Block{
      data: "ZERO_DATA",
      timestamp: 0,
      prev_hash: nil,
      hash: nil
    }
  end

  @doc """
  Check if a block is valid by verifying its hash.
  """
  def valid?(%Block{} = block) do
    block.hash == Crypto.hash(block)
  end
end
