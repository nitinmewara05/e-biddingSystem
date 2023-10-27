// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "contracts/biddingDapp/blockMaster.sol";

contract auctionContract {
    address payable auctionManager;
    BlockMaster public blockmaster;
    BiddersMaster bidderMaster;
    uint256 regNo;
    uint256 maxBidValue;
    uint chainNo;
    mapping(uint256 => BiddersMaster) auctionBidderRegister;
    mapping(uint256 => AuctionRegister) auctionChain;
AuctionRegister public  winner;
    //***********Constructor*********
    constructor() payable {
        auctionManager = payable(msg.sender);
        regNo = 0;
    }

    //***********Modifiers*********
    modifier checkAuctionManager() {
        require(
            msg.sender == auctionManager,
            "Error You are not Auction Manager"
        );
        _;
    }
    modifier checkUserIsNotAuctionManager() {
        require(
            msg.sender != auctionManager,
            "Action deny... Auction Manager can not place bid"
        );
        _;
    }
    modifier checkAuctionBidderRegister() {
        BiddersMaster memory bidBlock;
        bool token = false;
        uint256 regCnt = 0;
        while (regCnt < regNo) {
            bidBlock = auctionBidderRegister[regCnt];
            if (bidBlock.bidderAddress == msg.sender) {
                token = true;
                break;
            }
            regCnt++;
        }
        require(
            token == false,
            "action Deny... Dear Bidder You are already registered Bidder"
        );
        _;
    }
    modifier checkAuctionBidderExistance() {
        BiddersMaster memory bidBlock;
        bool token = false;
        uint256 regCnt = 0;
        while (regCnt < regNo) {
            bidBlock = auctionBidderRegister[regCnt];
            if (bidBlock.bidderAddress == msg.sender) {
                token = true;
                break;
            }
            regCnt++;
        }
        require(
            token == true,
            "action Deny... Dear Bidder register for auction"
        );
        _;
    }
      modifier checkWinnerAddress(){
        require(msg.sender == winner.userAddress,"Action Deny... You are not winner");
        _;
    }
    modifier checkTransactionValue(){
        uint ethtowei = winner.bidValue * 1000000000000000000;
        require(winner.bidValue == msg.value, "Invalid Transaction Value");
        _;
    }
    modifier itemBiddingStatus(){
        require(blockmaster.auctionResult==false,"Auction Over");
        _;
    }
    //****************Modifier with argument******************
    modifier checkBidValue(uint256 bidderValue) {
        require(bidderValue > maxBidValue, "Invalid Bid Value");
        _;
    }
  

    //***********Functions*********
    function setAuctionItem(string memory name, uint256 bidValue)
        public
        checkAuctionManager()
    {
        blockmaster = BlockMaster(name, bidValue,false);
        maxBidValue = bidValue;
        chainNo = 0;
    }

    //***************New Bidder Registration**************
    function bidderRegister(string memory name) public checkUserIsNotAuctionManager() checkAuctionBidderRegister()
    {
        auctionBidderRegister[regNo] = BiddersMaster(name,payable(msg.sender));
        goToNext();
    }

    function goToNext() private {
        regNo++;
    }

    function myBidding(uint256 myBidValue)
        public
        itemBiddingStatus()
        checkUserIsNotAuctionManager
        checkAuctionBidderExistance
        checkBidValue(myBidValue)
    {
        AuctionRegister memory auctionBlock = AuctionRegister(payable (msg.sender),myBidValue);
        auctionChain[chainNo] = auctionBlock;
        maxBidValue = myBidValue;
        goToNextBlockChain()
    }
    function goToNextBlockChain() private {
        chainNo++;
    }
    function declareAuctionResult() public checkAuctionManager() {
uint winnerIndex = chainNo - 1;
winner=auctionChain[winnerIndex];
blockmaster = BlockMaster(blockmaster.itemName,blockmaster.initBidValue,true);

    }

  function  transferBidAmount() public payable  checkAuctionManager() checkWinnerAddress() checkTransactionValue() {
auctionManager.transfer(msg.value);
    }
}
