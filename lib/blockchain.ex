defmodule Blockchain do
  @moduledoc """
  Blockchain operations and management.
  """

  @doc """
  Create a new blockchain with genesis block.
  """
  def new do
    genesis = Block.zero() |> Crypto.put_hash()
    [genesis]
  end

  @doc """
  Insert new data as a block into the blockchain.
  """
  def insert(blockchain, data) do
    prev_block = List.first(blockchain)

    new_block =
      Block.new(data, prev_block.hash)
      |> Crypto.put_hash()

    [new_block | blockchain]
  end

  @doc """
  Check if the entire blockchain is valid.
  """
  def valid?(blockchain) do
    blockchain
    |> Enum.reverse()
    |> validate_chain()
  end

  # Private function to validate the chain recursively
  defp validate_chain([genesis_block]), do: Block.valid?(genesis_block)

  defp validate_chain([block | [prev_block | _] = rest]) do
    Block.valid?(block, prev_block) && validate_chain(rest)
  end
end
