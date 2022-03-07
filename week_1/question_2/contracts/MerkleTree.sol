// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
MerkleTree is a contract used to store hashed meta data of every successful mint from the NFT contract.
The contract has five functions:
1. constructor: initializes sub trees with dummy values
2. zeros: provides dummy values for the sub trees
3. constructEmptyTree: helper function to compute initial dummy values
4. insert: external function which inserts a new element into the merkle tree and updates the merkle root accordingly.
           It is called from the NFT contract after every successful mint.
5. hashLeftRight: helper function to compute the hash value from two concatenated input values

The implementation was inspired by the Tornado Cash merkle tree contract which can be found here:
https://github.com/tornadocash/tornado-core/blob/master/contracts/MerkleTreeWithHistory.sol
*/
contract MerkleTree {
  uint32 public constant LEVELS = 4;
  mapping(uint256 => bytes32) public filledSubtrees; // hash values of filled sub trees
  bytes32 public rootHash; // hash value of root of merkle tree
  uint32 public nextIndex = 0; // index where the next element will be inserted into the merkle tree

  bytes32[] public hashes; // helper array to compute initial dummy values for sub trees
  string public ZERO_VALUE = "ZKU"; // dummy value

  /**
    Initialize filled sub trees and rootHash
   */
  constructor() {
    for (uint32 i = 0; i < LEVELS; i++) {
      filledSubtrees[i] = zeros(i);
    }

    rootHash = zeros(LEVELS - 1);
  }

  /**
    Hash two leave values  
  */
  function hashLeftRight(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
    bytes32 hashValue = keccak256(abi.encodePacked(_left, _right));
    return hashValue;
  }

  /**
    External function to insert new element into the merkle tree
  */  
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

  /**
    Helper function to compute initial values of merkle tree 
  */
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

  /**
    provides zero/dummy elements for sub trees of merkle tree. Up to 4 levels
  */
  function zeros(uint256 i) public pure returns (bytes32) {
    if (i == 0) return bytes32(0x429f7b6f725a9af81fd431fb46226ef1f84bbb45dc974dd64ca3d5a2c6c66128);
    else if (i == 1) return bytes32(0x76a533acc769b7e8fd28d878217a07226ac4228699fc846164d5ddfaea8a678a);
    else if (i == 2) return bytes32(0x7fc982728e0c785ad0969f7485bb810f666951b6f3c0fb0148bef5bcb626b10d);
    else if (i == 3) return bytes32(0xa09c58262d75edf9e87a136dcaa94b81863d518f43ccc5daef1ff985ea1a72d6);
    else revert("Index out of bounds");
  }
}