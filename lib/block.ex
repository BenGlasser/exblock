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
      timestamp: NaiveDateTime.utc_now(),
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
      timestamp: NaiveDateTime.utc_now(),
      prev_hash: "ZERO_HASH",
      hash: nil
    }
  end

  @doc """
  Check if a block is valid by verifying its hash.
  """
  def valid?(%Block{} = block) do
    block.hash == Crypto.hash(block)
  end

  @doc """
  Check if a block is valid in relation to a previous block.
  """
  def valid?(%Block{} = block, %Block{} = prev_block) do
    valid?(block) && block.prev_hash == prev_block.hash
  end
end
