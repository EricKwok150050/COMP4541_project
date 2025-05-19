// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedCasino {
    address public owner;
    mapping(address => uint256) public balances;

    event BetResult(address indexed user, uint256 amount, bool won);

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Must deposit some ETH");
        balances[msg.sender] += msg.value;
    }

    function ownerDeposit() public payable {
        require(msg.sender == owner, "Only owner can deposit funds");
    }

    function bet(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(address(this).balance >= amount * 2, "Casino cannot cover the bet");

        bool won = (block.timestamp % 2 == 0); // Simple 50/50 randomness
        if (won) {
            balances[msg.sender] += amount;
            payable(msg.sender).transfer(amount * 2);
        } else {
            balances[msg.sender] -= amount;
        }
        
        emit BetResult(msg.sender, amount, won);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function ownerWithdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(owner).transfer(amount);
    }
}