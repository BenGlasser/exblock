defmodule CryptoTest do
  use ExUnit.Case
  doctest Crypto

  describe "Crypto.hash/1" do
    test "generates consistent hash for same block data" do
      timestamp = NaiveDateTime.from_iso8601!("2023-01-01T00:00:00")

      block1 = %Block{
        data: "test data",
        timestamp: timestamp,
        prev_hash: "prev_hash"
      }

      block2 = %Block{
        data: "test data",
        timestamp: timestamp,
        prev_hash: "prev_hash"
      }

      hash1 = Crypto.hash(block1)
      hash2 = Crypto.hash(block2)

      assert hash1 == hash2
      assert is_binary(hash1)
      assert String.length(hash1) == 64  # SHA256 hex length
    end

    test "generates different hashes for different data" do
      timestamp = NaiveDateTime.from_iso8601!("2023-01-01T00:00:00")

      block1 = %Block{data: "data1", timestamp: timestamp, prev_hash: "prev"}
      block2 = %Block{data: "data2", timestamp: timestamp, prev_hash: "prev"}

      hash1 = Crypto.hash(block1)
      hash2 = Crypto.hash(block2)

      assert hash1 != hash2
    end

    test "generates different hashes for different timestamps" do
      block1 = %Block{
        data: "same data",
        timestamp: NaiveDateTime.from_iso8601!("2023-01-01T00:00:00"),
        prev_hash: "prev"
      }

      block2 = %Block{
        data: "same data",
        timestamp: NaiveDateTime.from_iso8601!("2023-01-01T00:00:01"),
        prev_hash: "prev"
      }

      hash1 = Crypto.hash(block1)
      hash2 = Crypto.hash(block2)

      assert hash1 != hash2
    end

    test "generates different hashes for different prev_hash" do
      timestamp = NaiveDateTime.from_iso8601!("2023-01-01T00:00:00")

      block1 = %Block{data: "data", timestamp: timestamp, prev_hash: "prev1"}
      block2 = %Block{data: "data", timestamp: timestamp, prev_hash: "prev2"}

      hash1 = Crypto.hash(block1)
      hash2 = Crypto.hash(block2)

      assert hash1 != hash2
    end

    test "ignores hash field when calculating hash" do
      timestamp = NaiveDateTime.from_iso8601!("2023-01-01T00:00:00")

      block1 = %Block{
        data: "data",
        timestamp: timestamp,
        prev_hash: "prev",
        hash: nil
      }

      block2 = %Block{
        data: "data",
        timestamp: timestamp,
        prev_hash: "prev",
        hash: "some_existing_hash"
      }

      hash1 = Crypto.hash(block1)
      hash2 = Crypto.hash(block2)

      assert hash1 == hash2
    end

    test "handles blocks with various data types" do
      timestamp = NaiveDateTime.from_iso8601!("2023-01-01T00:00:00")

      # String data
      string_block = %Block{data: "string", timestamp: timestamp, prev_hash: "prev"}

      # Number data
      number_block = %Block{data: 123, timestamp: timestamp, prev_hash: "prev"}

      # Map data
      map_block = %Block{data: %{key: "value"}, timestamp: timestamp, prev_hash: "prev"}

      string_hash = Crypto.hash(string_block)
      number_hash = Crypto.hash(number_block)
      map_hash = Crypto.hash(map_block)

      # All should generate valid hashes
      assert is_binary(string_hash)
      assert is_binary(number_hash)
      assert is_binary(map_hash)

      # All should be different
      assert string_hash != number_hash
      assert number_hash != map_hash
      assert string_hash != map_hash
    end
  end

  describe "Crypto.put_hash/1" do
    test "adds calculated hash to block" do
      block = Block.new("test data", "prev_hash")
      hashed_block = Crypto.put_hash(block)

      assert hashed_block.data == block.data
      assert hashed_block.timestamp == block.timestamp
      assert hashed_block.prev_hash == block.prev_hash
      assert is_binary(hashed_block.hash)
      assert String.length(hashed_block.hash) == 64
    end

    test "overwrites existing hash" do
      block = %Block{
        data: "data",
        timestamp: NaiveDateTime.utc_now(),
        prev_hash: "prev",
        hash: "old_hash"
      }

      hashed_block = Crypto.put_hash(block)

      assert hashed_block.hash != "old_hash"
      assert hashed_block.hash == Crypto.hash(block)
    end

    test "generated hash validates correctly" do
      block = Block.zero() |> Crypto.put_hash()

      assert Block.valid?(block) == true
    end

    test "works with genesis block" do
      zero_block = Block.zero()
      hashed_zero = Crypto.put_hash(zero_block)

      assert is_binary(hashed_zero.hash)
      assert Block.valid?(hashed_zero) == true
    end
  end

  describe "hash format" do
    test "generates uppercase hexadecimal hash" do
      block = Block.new("test", "prev")
      hash = Crypto.hash(block)

      # Should be uppercase hex (SHA256 produces uppercase with Base.encode16)
      assert hash =~ ~r/^[A-F0-9]{64}$/
    end

    test "consistent hash format across different blocks" do
      blocks = [
        Block.new("data1", "prev1"),
        Block.new("data2", "prev2"),
        Block.zero()
      ]

      for block <- blocks do
        hash = Crypto.hash(block)
        assert String.length(hash) == 64
        assert hash =~ ~r/^[A-F0-9]{64}$/
      end
    end
  end
end
