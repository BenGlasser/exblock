defmodule BlockTest do
  use ExUnit.Case
  doctest Block

  describe "Block.new/2" do
    test "creates a new block with given data and previous hash" do
      data = "test data"
      prev_hash = "previous_hash_123"

      block = Block.new(data, prev_hash)

      assert block.data == data
      assert block.prev_hash == prev_hash
      assert %NaiveDateTime{} = block.timestamp
      assert is_nil(block.hash)
    end

    test "creates blocks with different timestamps" do
      block1 = Block.new("data1", "hash1")
      :timer.sleep(1)  # Ensure different timestamps
      block2 = Block.new("data2", "hash2")

      assert NaiveDateTime.compare(block1.timestamp, block2.timestamp) == :lt
    end
  end

  describe "Block.zero/0" do
    test "creates genesis block with default values" do
      zero_block = Block.zero()

      assert zero_block.data == "ZERO_DATA"
      assert zero_block.prev_hash == "ZERO_HASH"
      assert %NaiveDateTime{} = zero_block.timestamp
      assert is_nil(zero_block.hash)
    end

    test "creates genesis blocks with different timestamps" do
      zero1 = Block.zero()
      :timer.sleep(1)
      zero2 = Block.zero()

      assert NaiveDateTime.compare(zero1.timestamp, zero2.timestamp) == :lt
    end
  end

  describe "Block.valid?/1" do
    test "validates block when hash matches calculated hash" do
      block = Block.zero() |> Crypto.put_hash()

      assert Block.valid?(block) == true
    end

    test "invalidates block when hash doesn't match" do
      block = %Block{
        data: "test",
        timestamp: NaiveDateTime.utc_now(),
        prev_hash: "prev",
        hash: "wrong_hash"
      }

      assert Block.valid?(block) == false
    end

    test "handles block without hash" do
      block = Block.new("test", "prev")

      assert Block.valid?(block) == false
    end
  end

  describe "Block.valid?/2" do
    test "validates block against previous block when both are valid" do
      prev_block = Block.zero() |> Crypto.put_hash()
      current_block = Block.new("data", prev_block.hash) |> Crypto.put_hash()

      assert Block.valid?(current_block, prev_block) == true
    end

    test "invalidates when previous hash doesn't match" do
      prev_block = Block.zero() |> Crypto.put_hash()
      current_block = Block.new("data", "wrong_hash") |> Crypto.put_hash()

      assert Block.valid?(current_block, prev_block) == false
    end

    test "invalidates when current block hash is wrong" do
      prev_block = Block.zero() |> Crypto.put_hash()
      current_block = %Block{
        data: "data",
        timestamp: NaiveDateTime.utc_now(),
        prev_hash: prev_block.hash,
        hash: "wrong_hash"
      }

      assert Block.valid?(current_block, prev_block) == false
    end

    test "validates chain of multiple blocks" do
      block1 = Block.zero() |> Crypto.put_hash()
      block2 = Block.new("data1", block1.hash) |> Crypto.put_hash()
      block3 = Block.new("data2", block2.hash) |> Crypto.put_hash()

      assert Block.valid?(block2, block1) == true
      assert Block.valid?(block3, block2) == true
    end
  end
end
