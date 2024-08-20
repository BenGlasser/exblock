# ExBlock - Simple Blockchain in Elixir

A simple blockchain implementation in Elixir based on the guide from [Writing a Simple Blockchain in Elixir](https://shyr.io/blog/writing-blockchain-elixir).

## Overview

This project implements a basic blockchain with the following features:

- **Block Structure**: Each block contains data, timestamp, previous hash, and its own hash
- **Cryptographic Hashing**: Uses SHA256 for block validation and chain integrity
- **Chain Validation**: Ensures the entire blockchain is valid by verifying hash connections
- **Immutable**: Once data is added to a block, it cannot be changed without invalidating the chain

## Project Structure

```
lib/
├── block.ex       # Block structure and validation
├── crypto.ex      # Cryptographic hashing functions
├── blockchain.ex  # Blockchain operations (create, insert, validate)
└── ex_block.ex    # Main module (generated)
```

## Modules

### Block

Defines the block structure and validation:
- `new/2` - Creates a new block with data and previous hash
- `zero/0` - Creates the genesis block
- `valid?/1` and `valid?/2` - Validates block integrity

### Crypto

Handles cryptographic operations:
- `hash/1` - Calculates SHA256 hash of a block
- `put_hash/1` - Adds the calculated hash to a block

### Blockchain

Main blockchain operations:
- `new/0` - Creates a new blockchain with genesis block
- `insert/2` - Adds new data as a block to the chain
- `valid?/1` - Validates the entire blockchain

## Usage

### Installation

```bash
mix deps.get
mix compile
```

### Testing

Run the test script to see the blockchain in action:

```bash
mix run test_blockchain.exs
```

### Interactive Session

Start an interactive Elixir session:

```bash
iex -S mix
```

Then try the blockchain:

```elixir
# Create a new blockchain
chain = Blockchain.new()

# Add some data
chain = Blockchain.insert(chain, "Hello, World!")
chain = Blockchain.insert(chain, "Another message")

# Validate the chain
Blockchain.valid?(chain)  # Should return true
```

## Example Output

```
=== Simple Blockchain Test ===

1. Creating a new blockchain...
2. Inserting 'MESSAGE 1'...
3. Inserting 'MESSAGE 2' and 'MESSAGE 3'...
4. Validating the blockchain...
Blockchain is valid: true

5. Block details:
Block 0: ZERO_DATA (Hash: EF475D8687640B5D...)
Block 1: MESSAGE 1 (Hash: 68D4C1D238A4A706...)
Block 2: MESSAGE 2 (Hash: 6F6F0B06163ECA14...)
Block 3: MESSAGE 3 (Hash: 0E45ECC20596D432...)
```

## Features Not Implemented

This is a simplified blockchain for educational purposes. Production blockchains would include:

- Public-key cryptography and digital signatures
- Proof-of-work or other consensus mechanisms
- Network communication and node synchronization
- Persistent storage
- Transaction handling
- Merkle trees for efficient validation

## Dependencies

- `poison` - JSON encoding/decoding for hash calculations

## Credits

Based on the excellent tutorial by Sheharyar Naseer: [Writing a Simple Blockchain in Elixir](https://shyr.io/blog/writing-blockchain-elixir)

