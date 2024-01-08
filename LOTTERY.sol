// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Lottery {
    address public manager; //The manager who initiates the lottery
    address[] public players; // List of participants
    uint public minimumBet; // Minimum amount required to enter the lottery 
    uint public lotteryEndTime; // Timestamp when the lottery ends 
    address public winner; // Address of winner 
    bool public lotteryEnded; //Flag indicating whether the lottery has ended

    event LotteryStarted(address indexed manager, uint minimumBet, uint lotteryEndTime);
    event TicketPurchased(address indexed player, uint amount);
    event LotteryEnded(address indexed winner, uint pricepool);

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }
    modifier notEnded() {
        require(!lotteryEnded, "Lottery has already ended");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp >= lotteryEndTime, "Lottery has not ended yet");
        _;
    }

    constructor(uint _minimumBet, uint _lotteryDurationDays){
        manager = msg.sender;
        minimumBet = _minimumBet;
        lotteryEndTime = block.timestamp + _lotteryDurationDays * 1 days;

        emit LotteryStarted( manager, minimumBet, lotteryEndTime);
    }

    function enterLottery() external payable notEnded {
    require(msg.value >= minimumBet, "Insufficient funds to enter the lottery");

    players.push(msg.sender);

    emit TicketPurchased(msg.sender, msg.value);
    }

    function endLottery() external onlyManager onlyAfterEnd notEnded{
        uint index = random() % players.length;
        winner = players[index];
        lotteryEnded = true;

        emit LotteryEnded(winner, address (this).balance);

        //Transfer the prize pool to the winner

        payable(winner).transfer(address(this).balance);
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp,players)));
    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }
}