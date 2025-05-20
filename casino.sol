// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedCasino {
    address public owner;
    mapping(address => uint256) public balances;
    uint randNonce = 0; //for random number generation

    event BetResult(address indexed user, uint256 amount, bool won);
    event rouletteResult(address indexed user, uint256 amount, uint256 betType, uint256 betValue, uint256 winningNumber, uint256 winAmount);

    constructor() {
        owner = msg.sender;
    }

    function randomNumber() public returns(uint)
    {
        // increase nonce
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce)));
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
        require(amount > 0, "Invalid bet amount");
        require(address(this).balance >= amount * 2, "Casino cannot cover the bet");

        uint256 randomNum = randomNumber() % 2;
        bool won = (randomNum == 1);

        emit BetResult(msg.sender, amount, won);

        if (won) {
            balances[msg.sender] += amount;
            balances[owner] -= amount;
        } else {
            balances[msg.sender] -= amount;
            balances[owner] += amount;
        }
    }

    function rouletteBet(uint256 amount, uint256 betType, uint256 betValue) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Invalid bet amount");
        require(address(this).balance >= amount * 35, "Casino cannot cover the bet");

        uint256 winAmount = 0;

        uint256 winningNumber = randomNumber() % 37; // 0-36 for roulette
        
        if (betType == 1 && betValue == winningNumber) { // Bet on a specific number
            winAmount = amount * 35; // Payout for winning on a number
        } else if (betType == 2 && ((winningNumber % 2 == 0) == (betValue == 0)) && winningNumber != 0) { // Even/Odd bet
            winAmount = amount; // Payout for winning on even/odd
        } else if (betType == 3) { // Color bet
            bool isRed = (winningNumber == 32 || winningNumber == 19 || winningNumber == 21 || 
                          winningNumber == 25 || winningNumber == 34 || winningNumber == 27 || 
                          winningNumber == 36 || winningNumber == 30 || winningNumber == 23 || 
                          winningNumber == 5 || winningNumber == 16 || winningNumber == 1 || 
                          winningNumber == 14 || winningNumber == 9 || winningNumber == 18 || 
                          winningNumber == 7 || winningNumber == 12 || winningNumber == 3);
            if ((betValue == 1 && isRed) || (betValue == 0 && !isRed && winningNumber != 0)) {
                winAmount = amount; // Payout for winning on color
            }
        }

        if (winAmount > 0) {
            balances[msg.sender] += winAmount;
            balances[owner] -= winAmount;
        } else {
            balances[msg.sender] -= amount;
            balances[owner] += amount;
        }

        emit rouletteResult(msg.sender, amount, betType, betValue, winningNumber, winAmount);

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