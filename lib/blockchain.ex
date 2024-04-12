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
end
