// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IEntropyConsumer } from "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import { IEntropyV2 } from "@pythnetwork/entropy-sdk-solidity/IEntropyV2.sol";

interface IERC20 {
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function transfer(address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}
 
// @param entropyAddress The address of the entropy contract.
// @param wagerAmount The wager amount in wei.
// @param usdcAddress The address of the USDC token contract.
contract Snake is IEntropyConsumer {
  IEntropyV2 public entropy;
  bytes32 public number;
  uint256 public numberAsUint;
  uint256 public wagerAmount;
  address public usdcAddress;
  
  // Player balances and ready states
  uint256 public player1Balance;
  uint256 public player2Balance;
  bool public player1Ready;
  bool public player2Ready;
 
  constructor(address entropyAddress, uint256 _wagerAmount, address _usdcAddress) {
    entropy = IEntropyV2(entropyAddress);
    wagerAmount = _wagerAmount;
    usdcAddress = _usdcAddress;
  }

  function requestRandomNumber() external payable {
    uint256 fee = entropy.getFeeV2();
    uint64 sequenceNumber = entropy.requestV2{ value: fee }();
  }

  // Player 1 wager function - accepts USDC and ETH (for Pyth fee)
  function wagerPlayer1() external payable {
    require(!player1Ready, "Player 1 already ready");
    uint256 fee = entropy.getFeeV2();
    require(msg.value >= fee, "Insufficient ETH for Pyth fee");
    
    // Transfer USDC from user to contract
    IERC20 usdc = IERC20(usdcAddress);
    require(usdc.transferFrom(msg.sender, address(this), wagerAmount), "USDC transfer failed");
    
    // Set player 1 ready state
    player1Ready = true;
    
    // Request random number (payable to Pyth with ETH)
    entropy.requestV2{ value: fee }();
    
    // Refund excess ETH if any
    if (msg.value > fee) {
      payable(msg.sender).transfer(msg.value - fee);
    }
  }

  // Player 2 wager function - accepts USDC and ETH (for Pyth fee)
  function wagerPlayer2() external payable {
    require(!player2Ready, "Player 2 already ready");
    uint256 fee = entropy.getFeeV2();
    require(msg.value >= fee, "Insufficient ETH for Pyth fee");
    
    // Transfer USDC from user to contract
    IERC20 usdc = IERC20(usdcAddress);
    require(usdc.transferFrom(msg.sender, address(this), wagerAmount), "USDC transfer failed");
    
    // Set player 2 ready state
    player2Ready = true;
    
    // Request random number (payable to Pyth with ETH)
    entropy.requestV2{ value: fee }();
    
    // Refund excess ETH if any
    if (msg.value > fee) {
      payable(msg.sender).transfer(msg.value - fee);
    }
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

 

