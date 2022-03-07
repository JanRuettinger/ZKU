// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IMerkleTree {
    function insert(bytes32 _leaf) external returns (uint32 index);
}

contract ZKPNFT is ERC721{

    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdCounter;
    IMerkleTree public immutable tree;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    constructor(IMerkleTree _tree) ERC721("ZKP NFT", "ZKP_NFT") {
        tree = _tree;
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "ZKP_NFT #', tokenId.toString(), '"',
                '"description":, "This is a super rare ZKP NFT created for ZKU."',
                // Replace with extra ERC721 Metadata properties
            '}'
        );

        string memory _tokenURI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
         _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        bytes32 newLeaf = keccak256(abi.encodePacked(msg.sender, to, tokenId, _tokenURI));
        tree.insert(newLeaf);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no base URI, return the token URI.
        return _tokenURI;
    }
}