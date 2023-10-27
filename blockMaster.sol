// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

struct BlockMaster{
      string itemName;
      uint initBidValue;
      bool auctionResult;
}
struct BiddersMaster{
    string bidderName;
    address payable bidderAddress;
    
}
struct AuctionRegister{
address payable userAddress;
uint bidValue;

}