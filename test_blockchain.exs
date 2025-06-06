IO.puts "=== Simple Blockchain Test ==="

IO.puts "\n1. Creating a new blockchain..."
chain = Blockchain.new()

IO.puts "2. Inserting 'MESSAGE 1'..."
chain = Blockchain.insert(chain, "MESSAGE 1")

IO.puts "3. Inserting 'MESSAGE 2' and 'MESSAGE 3'..."
chain = Blockchain.insert(chain, "MESSAGE 2")
chain = Blockchain.insert(chain, "MESSAGE 3")

IO.puts "4. Validating the blockchain..."
is_valid = Blockchain.valid?(chain)
IO.puts "Blockchain is valid: #{is_valid}"

IO.puts "\n5. Block details:"
chain
|> Enum.reverse()
|> Enum.with_index()
|> Enum.each(fn {block, index} ->
  hash_preview = String.slice(block.hash, 0, 16) <> "..."
  IO.puts "Block #{index}: #{block.data} (Hash: #{hash_preview})"
end)
