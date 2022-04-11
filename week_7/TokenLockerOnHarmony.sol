// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "./EthereumLightClient.sol";
import "./EthereumProver.sol";
import "./TokenLocker.sol";

// This contract checks if the proof showing that ERC20 tokens were locked on Ethereum is correct.
// The only important function to understand the functionality is validateAndExecuteProof().
// Since the Ethereum chain doesn't yet support MRR root information in block headers, different checks are required to 
// make sure that a transaction is actually valid and included.
// The function takes an block number, a root hash, an mptkey and a proof and does the following:
// 1. Gets the block hash from the block number (saves gas probably)
// 2. Checks if the provided receipt hash was actually part of the last block
// 3. Checks if the bridged tokens were spent already (to avoid double spending)
// 4. Checks if the transaction is actually part of the block with a Merkle Proof

contract TokenLockerOnHarmony is TokenLocker, OwnableUpgradeable {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    EthereumLightClient public lightclient;

    mapping(bytes32 => bool) public spentReceipt;

    function initialize() external initializer {
        __Ownable_init();
    }

    function changeLightClient(EthereumLightClient newClient)
        external
        onlyOwner
    {
        lightclient = newClient;
    }

    function bind(address otherSide) external onlyOwner {
        otherSideBridge = otherSide;
    }

    function validateAndExecuteProof(
        uint256 blockNo,
        bytes32 rootHash,
        bytes calldata mptkey,
        bytes calldata proof
    ) external {
        bytes32 blockHash = bytes32(lightclient.blocksByHeight(blockNo, 0));
        require(
            lightclient.VerifyReceiptsHash(blockHash, rootHash),
            "wrong receipt hash"
        );
        bytes32 receiptHash = keccak256(
            abi.encodePacked(blockHash, rootHash, mptkey)
        );
        require(spentReceipt[receiptHash] == false, "double spent!");
        bytes memory rlpdata = EthereumProver.validateMPTProof(
            rootHash,
            mptkey,
            proof
        );
        spentReceipt[receiptHash] = true;
        uint256 executedEvents = execute(rlpdata);
        require(executedEvents > 0, "no valid event");
    }
}
