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
        require(msg.value > 0, "Must deposit some ETH");
        require(msg.sender == owner, "Only owner can deposit funds");
        balances[owner] += msg.value;
    }

    function bet(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(address(this).balance >= amount * 2, "Casino cannot cover the bet");

        uint256 randomNum = uint256(blockhash(block.number - 1)) % 2;
        bool won = (randomNum == 1);

        emit BetResult(msg.sender, amount, won);

        if (won) {
            balances[msg.sender] += amount;
        } else {
            balances[msg.sender] -= amount;
        }
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function ownerWithdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(balances[owner] >= amount, "Insufficient contract balance");
        balances[owner] -= amount;
        payable(owner).transfer(amount);
    }
}