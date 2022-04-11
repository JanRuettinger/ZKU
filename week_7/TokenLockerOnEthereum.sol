// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

import "./HarmonyLightClient.sol";
import "./lib/MMRVerifier.sol";
import "./HarmonyProver.sol";
import "./TokenLocker.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// This contract checks if the proof showing that HRC20 tokens were locked/burnt on Harmony is correct.
// The only important function to understand the functionality is validateAndExecuteProof().
// The function takes a Harmony block header, a MMR proof and a receiptdata. merkle tree proof and does the following:
// 1. Checks if the MMR root is a valid checkpoint aka if the MMR root represents an epoch
// 2. Checks if the header is actually part of the epoch
// 3. Checks if the bridged tokens were spent already (to avoid double spending)
// 4. Checks if the transaction is actually part of the block with a Merkle Proof

contract TokenLockerOnEthereum is TokenLocker, OwnableUpgradeable {
    HarmonyLightClient public lightclient;

    mapping(bytes32 => bool) public spentReceipt;

    function initialize() external initializer {
        __Ownable_init();
    }

    function changeLightClient(HarmonyLightClient newClient)
        external
        onlyOwner
    {
        lightclient = newClient;
    }

    function bind(address otherSide) external onlyOwner {
        otherSideBridge = otherSide;
    }



    function validateAndExecuteProof(
        HarmonyParser.BlockHeader memory header,
        MMRVerifier.MMRProof memory mmrProof,
        MPT.MerkleProof memory receiptdata
    ) external {
        require(lightclient.isValidCheckPoint(header.epoch, mmrProof.root), "checkpoint validation failed");
        bytes32 blockHash = HarmonyParser.getBlockHash(header);
        bytes32 rootHash = header.receiptsRoot;
        (bool status, string memory message) = HarmonyProver.verifyHeader(
            header,
            mmrProof
        );
        require(status, "block header could not be verified");
        bytes32 receiptHash = keccak256(
            abi.encodePacked(blockHash, rootHash, receiptdata.key)
        );
        require(spentReceipt[receiptHash] == false, "double spent!");
        (status, message) = HarmonyProver.verifyReceipt(header, receiptdata);
        require(status, "receipt data could not be verified");
        spentReceipt[receiptHash] = true;
        uint256 executedEvents = execute(receiptdata.expectedValue);
        require(executedEvents > 0, "no valid event");
    }
}
