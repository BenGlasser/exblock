defmodule BlockchainTest do
  use ExUnit.Case
  doctest Blockchain

  describe "Blockchain.new/0" do
    test "creates blockchain with genesis block" do
      chain = Blockchain.new()

      assert is_list(chain)
      assert length(chain) == 1

      [genesis] = chain
      assert genesis.data == "ZERO_DATA"
      assert genesis.prev_hash == "ZERO_HASH"
      assert is_binary(genesis.hash)
      assert Block.valid?(genesis) == true
    end

    test "each new blockchain has different genesis timestamp" do
      chain1 = Blockchain.new()
      :timer.sleep(1)
      chain2 = Blockchain.new()

      [genesis1] = chain1
      [genesis2] = chain2

      assert NaiveDateTime.compare(genesis1.timestamp, genesis2.timestamp) == :lt
    end

    test "genesis block is properly hashed" do
      chain = Blockchain.new()
      [genesis] = chain

      # Hash should match the calculated hash
      assert genesis.hash == Crypto.hash(genesis)
    end
  end

  describe "Blockchain.insert/2" do
    test "inserts new block with correct linkage" do
      chain = Blockchain.new()
      [genesis] = chain

      updated_chain = Blockchain.insert(chain, "First message")

      assert length(updated_chain) == 2
      [new_block, genesis_block] = updated_chain

      # New block should reference genesis hash
      assert new_block.prev_hash == genesis.hash
      assert new_block.data == "First message"
      assert is_binary(new_block.hash)
      assert Block.valid?(new_block) == true

      # Genesis should be unchanged
      assert genesis_block == genesis
    end

    test "inserts multiple blocks in correct order" do
      chain = Blockchain.new()

      chain = chain
      |> Blockchain.insert("Message 1")
      |> Blockchain.insert("Message 2")
      |> Blockchain.insert("Message 3")

      assert length(chain) == 4
      [block3, block2, block1, genesis] = chain

      # Check data
      assert genesis.data == "ZERO_DATA"
      assert block1.data == "Message 1"
      assert block2.data == "Message 2"
      assert block3.data == "Message 3"

      # Check hash linkage
      assert block1.prev_hash == genesis.hash
      assert block2.prev_hash == block1.hash
      assert block3.prev_hash == block2.hash
    end

    test "maintains blockchain integrity after multiple insertions" do
      chain = Blockchain.new()

      # Add several blocks
      messages = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon"]
      final_chain = Enum.reduce(messages, chain, fn msg, acc ->
        Blockchain.insert(acc, msg)
      end)

      assert length(final_chain) == 6  # Genesis + 5 messages
      assert Blockchain.valid?(final_chain) == true
    end

    test "handles different data types" do
      chain = Blockchain.new()

      chain = chain
      |> Blockchain.insert("string data")
      |> Blockchain.insert(42)
      |> Blockchain.insert(%{key: "value", number: 123})
      |> Blockchain.insert(["list", "of", "items"])

      assert length(chain) == 5
      assert Blockchain.valid?(chain) == true

      [list_block, map_block, number_block, string_block, _genesis] = chain

      assert string_block.data == "string data"
      assert number_block.data == 42
      assert map_block.data == %{key: "value", number: 123}
      assert list_block.data == ["list", "of", "items"]
    end

    test "each inserted block has unique timestamp" do
      chain = Blockchain.new()

      chain = Blockchain.insert(chain, "Message 1")
      :timer.sleep(1)
      chain = Blockchain.insert(chain, "Message 2")

      [block2, block1, _genesis] = chain

      assert NaiveDateTime.compare(block1.timestamp, block2.timestamp) == :lt
    end
  end

  describe "Blockchain.valid?/1" do
    test "validates correct blockchain" do
      chain = Blockchain.new()
      |> Blockchain.insert("Message 1")
      |> Blockchain.insert("Message 2")
      |> Blockchain.insert("Message 3")

      assert Blockchain.valid?(chain) == true
    end

    test "validates single genesis block" do
      chain = Blockchain.new()

      assert Blockchain.valid?(chain) == true
    end

    test "invalidates blockchain with corrupted block hash" do
      chain = Blockchain.new()
      |> Blockchain.insert("Message 1")
      |> Blockchain.insert("Message 2")

      # Corrupt the middle block's hash
      [block2, block1, genesis] = chain
      corrupted_block1 = %{block1 | hash: "CORRUPTED_HASH"}
      corrupted_chain = [block2, corrupted_block1, genesis]

      assert Blockchain.valid?(corrupted_chain) == false
    end

    test "invalidates blockchain with broken linkage" do
      chain = Blockchain.new()
      |> Blockchain.insert("Message 1")
      |> Blockchain.insert("Message 2")

      # Break the linkage by changing prev_hash
      [block2, block1, genesis] = chain
      broken_block2 = %{block2 | prev_hash: "WRONG_PREV_HASH"}
      broken_chain = [broken_block2, block1, genesis]

      assert Blockchain.valid?(broken_chain) == false
    end

    test "invalidates blockchain with corrupted genesis" do
      chain = Blockchain.new()
      |> Blockchain.insert("Message 1")

      # Corrupt genesis block
      [block1, genesis] = chain
      corrupted_genesis = %{genesis | data: "CORRUPTED_GENESIS"}
      corrupted_chain = [block1, corrupted_genesis]

      assert Blockchain.valid?(corrupted_chain) == false
    end

    test "handles empty blockchain" do
      assert Blockchain.valid?([]) == false
    end

    test "validates long blockchain" do
      chain = Blockchain.new()

      # Create a long chain
      long_chain = Enum.reduce(1..100, chain, fn i, acc ->
        Blockchain.insert(acc, "Message #{i}")
      end)

      assert length(long_chain) == 101  # Genesis + 100 messages
      assert Blockchain.valid?(long_chain) == true
    end

    test "detects tampering anywhere in the chain" do
      # Create a long chain
      chain = Enum.reduce(1..10, Blockchain.new(), fn i, acc ->
        Blockchain.insert(acc, "Message #{i}")
      end)

      # Tamper with a block in the middle
      blocks = Enum.to_list(chain)
      middle_index = div(length(blocks), 2)

      {before, [middle | remaining]} = Enum.split(blocks, middle_index)
      tampered_middle = %{middle | data: "TAMPERED DATA"}
      tampered_chain = before ++ [tampered_middle | remaining]

      assert Blockchain.valid?(tampered_chain) == false
    end
  end

  describe "blockchain properties" do
    test "blockchain maintains chronological order" do
      chain = Blockchain.new()

      # Add blocks with delays to ensure different timestamps
      chain = Blockchain.insert(chain, "First")
      :timer.sleep(1)
      chain = Blockchain.insert(chain, "Second")
      :timer.sleep(1)
      chain = Blockchain.insert(chain, "Third")

      [third, second, first, genesis] = chain

      # Check timestamps are in order (most recent first in list)
      assert NaiveDateTime.compare(genesis.timestamp, first.timestamp) == :lt
      assert NaiveDateTime.compare(first.timestamp, second.timestamp) == :lt
      assert NaiveDateTime.compare(second.timestamp, third.timestamp) == :lt
    end

    test "blockchain is immutable - inserting doesn't modify original" do
      original_chain = Blockchain.new()
      [original_genesis] = original_chain

      new_chain = Blockchain.insert(original_chain, "New message")

      # Original chain should be unchanged
      assert length(original_chain) == 1
      assert hd(original_chain) == original_genesis

      # New chain should have additional block
      assert length(new_chain) == 2
    end

    test "each block has unique hash" do
      chain = Blockchain.new()
      |> Blockchain.insert("Message 1")
      |> Blockchain.insert("Message 2")
      |> Blockchain.insert("Message 3")

      hashes = Enum.map(chain, fn block -> block.hash end)
      unique_hashes = Enum.uniq(hashes)

      assert length(hashes) == length(unique_hashes)
    end
  end
end
