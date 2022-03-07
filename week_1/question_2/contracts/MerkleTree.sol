// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MerkleTreeWithHistory {
  uint32 public constant LEVELS = 4;

  // filledSubtrees and roots could be bytes32[size], but using mappings makes it cheaper because
  // it removes index range check on every interaction
  mapping(uint256 => bytes32) public filledSubtrees;
  bytes32 public rootHash;
  uint32 public nextIndex = 0;
  bytes32[] public hashes;
  string public ZERO_VALUE = "ZKU";

  constructor() {
    for (uint32 i = 0; i < LEVELS; i++) {
      filledSubtrees[i] = zeros(i);
    }

    rootHash = zeros(LEVELS - 1);
  }

  /**
    @dev Hash 2 tree leaves, returns MiMC(_left, _right)
  */
  function hashLeftRight(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
    bytes32 hashValue = keccak256(abi.encodePacked(_left, _right));
    return hashValue;
  }

  function insert(bytes32 _leaf) public returns (uint32 index) {
    uint32 _nextIndex = nextIndex;
    require(_nextIndex != uint32(2)**LEVELS, "Merkle tree is full. No more leaves can be added");
    uint32 currentIndex = _nextIndex;
    bytes32 currentLevelHash = _leaf;
    bytes32 left;
    bytes32 right;

    for (uint32 i = 0; i < LEVELS; i++) {
      if (currentIndex % 2 == 0) {
        left = currentLevelHash;
        right = zeros(i);
        filledSubtrees[i] = currentLevelHash;
      } else {
        left = filledSubtrees[i];
        right = currentLevelHash;
      }
      currentLevelHash = hashLeftRight(left, right);
      currentIndex /= 2;
    }

    rootHash = currentLevelHash;
    nextIndex = _nextIndex + 1;
    return _nextIndex;
  }

  function constructEmptyTree() public returns (bytes32 [] memory _hashes){
    delete hashes;
    bytes32 ZERO_HASH = keccak256(bytes(ZERO_VALUE));
    for(uint i=0;i<2**(LEVELS-1);i++){
        hashes.push(ZERO_HASH);
    }

    uint n = 2**(LEVELS-1);
    uint offset = 0;

    while (n > 0) {
        for (uint i = 0; i < n - 1; i += 2) {
            hashes.push(
                keccak256(
                    abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                )
            );
        }
        offset += n;
        n = n / 2;
    }

    _hashes = hashes;
    return _hashes;
  }

  /// @dev provides Zero (Empty) elements for a MiMC MerkleTree. Up to 32 levels
  function zeros(uint256 i) public pure returns (bytes32) {
    if (i == 0) return bytes32(0x429f7b6f725a9af81fd431fb46226ef1f84bbb45dc974dd64ca3d5a2c6c66128);
    else if (i == 1) return bytes32(0x76a533acc769b7e8fd28d878217a07226ac4228699fc846164d5ddfaea8a678a);
    else if (i == 2) return bytes32(0x7fc982728e0c785ad0969f7485bb810f666951b6f3c0fb0148bef5bcb626b10d);
    else if (i == 3) return bytes32(0xa09c58262d75edf9e87a136dcaa94b81863d518f43ccc5daef1ff985ea1a72d6);
    else revert("Index out of bounds");
  }
}