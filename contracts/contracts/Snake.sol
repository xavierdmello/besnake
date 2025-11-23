// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IEntropyConsumer } from "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import { IEntropyV2 } from "@pythnetwork/entropy-sdk-solidity/IEntropyV2.sol";
 
// @param entropyAddress The address of the entropy contract.
// @param wagerAmount The wager amount in wei.
// @param usdcAddress The address of the USDC token contract.
contract Snake is IEntropyConsumer {
  IEntropyV2 public entropy;
  bytes32 public number;
  uint256 public numberAsUint;
  uint256 public wagerAmount;
  address public usdcAddress;
 
  constructor(address entropyAddress, uint256 _wagerAmount, address _usdcAddress) {
    entropy = IEntropyV2(entropyAddress);
    wagerAmount = _wagerAmount;
    usdcAddress = _usdcAddress;
  }

  function requestRandomNumber() external payable {
    uint256 fee = entropy.getFeeV2();
    uint64 sequenceNumber = entropy.requestV2{ value: fee }();
  }
 

   function entropyCallback(
    uint64 sequenceNumber,
    address provider,
    bytes32 randomNumber
  ) internal override {
    number = randomNumber;
    numberAsUint = uint256(randomNumber);
  }

  // This method is required by the IEntropyConsumer interface.
  // It returns the address of the entropy contract which will call the callback.
  function getEntropy() internal view override returns (address) {
    return address(entropy);
  }
}

 

